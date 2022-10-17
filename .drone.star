"""
The pipeline triggers build of PR environment once Pull Request submitted to staging branch. Site URL is pr-PR_NUMBER.printyourfood.com
The pipeline triggers build of Staging environment once anything pushed to staging branch. Site URL staging.printyourfood.com
The pipeline triggers build of Preproduction environment once Pull Request submitted to master branch. Site URL preproduction.printyourfood.com
The pipeline artifacts build of Production environment are triggered by merge to master branch. Artifacts deployment to Production triggered by promoting push to master branch with "production" keyword
"""
MICROSERVICES_FRONTEND = {
    "frontend": "websites/main",
    "streaming": "websites/streaming",
}

MICROSERVICES_BACKEND = {
    "backend": "apis/backend",
    "auth-server": "apis/auth",
    "scheduler": "services/crons",
    "sync-image-server": "services/optimize-image",
    "post-processing": "services/post-processing",
    "sync-video-server": "services/sync-video",
}

ENVIRONMENTS = [
    "pr",
    "staging",
    "preproduction",
    "production",
]

STAGING_KUBE_SETTINGS = {
    "KUBE_API_SERVER": "kube_server_staging",
    "KUBE_TOKEN": "kube_token_staging",
}

PRODUCTION_KUBE_SETTINGS = {
    "KUBE_API_SERVER": "kube_server_production",
    "KUBE_TOKEN": "kube_token_production",
}

STAGING_POSTGRES_SECRETS = {
    "PG_CONN_STRING": "pg_conn_string",
    "PG_CONN_STRING_ADMIN": "pg_conn_string_admin",
}

PRODUCTION_CLOUDFLARE_SECRETS = {
    "api_token": "cloudflare_api_token",
    "zone_identifier": "production_cloudflare_zone_id",
}

STAGING_CLOUDFLARE_SECRETS = {
    "api_token": "cloudflare_api_token",
    "zone_identifier": "staging_cloudflare_zone_id",
}


IMAGE_BUILD_TAGS = [
    "${DRONE_COMMIT}",
    "${DRONE_COMMIT_BRANCH}",
    "${DRONE_COMMIT_BRANCH}-${DRONE_BUILD_NUMBER}"
]

PIPELINE_TRIGGERS = {
    "pr": [
        [ "staging", ],
        [ "pull_request", ],
        "include",
        "include"
    ],
    "staging": [
        [ "staging", ],
        [ "promote", "pull_request", ],
        "include",
        "exclude",
    ],
    "preproduction": [
        [ "master", ],
        [ "pull_request", ],
        "include",
        "include",
    ],
    "production": [
        [ "master" ],
        [ "pull_request", ],
        "include",
        "exclude",
    ],
    "build_production": [
        [ "master", ],
        [ "push", ],
        "include",
        "include",
    ],
    "deploy_production": [
        [ "master", ],
        [ "promote", ],
        "include",
        "include",
        [ "production", ],
    ],
}

def _generate_pipeline_triggers(branches=[], events=[], branch_mode="include", event_mode="include", promotions=[]):
    """
    Generate triggers from inputs
    @param branches - a list of branches for branch trigger, list
    @param events - a list of events for event trigger, list
    @param branch_mode - a mode for branch trigger, string
    @param event_mode - a mode for event trigger, string
    @param promotions - a list of promotion triggers, list
    @return triggers, dict
    """
    triggers = {
        "branch": {},
        "event": {},
    }

    triggers["branch"][branch_mode] = branches
    triggers["event"][event_mode] = events

    if promotions:
        triggers["target"] = promotions

    return triggers

def _generate_env_from_secrets(params, extra_args={}):
    """
    Generate envs from secrets
    @param - a map of extra arguments, dict
    @param params - a map of environment variable and a name of Drone secret, dict
    @return environment data, dict
    """
    env_data = {}
    for env, secret in params.items():
        env_data[env] = {
            "from_secret": secret,
        }
    return dict(env_data, **extra_args)

def _purge_cloudflare_cache(environment):
    """
    Generate Purge CloudFlare Cache steps

    @param environment - a name of environment, string
    @return Purge CloudFlare Cache steps, dict
    """
    if environment == "production":
        environment = "deploy_production"
        defaults = {
            "settings": _generate_env_from_secrets(
                PRODUCTION_CLOUDFLARE_SECRETS, {"action": "purge_everything"}
            ),
        }
    else:
        defaults = {
            "settings": _generate_env_from_secrets(
                STAGING_CLOUDFLARE_SECRETS, {"action": "purge_everything"}
            ),
        }
    defaults["when"] = _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment])
    return defaults


def _build_setting(build_context, registry_path, extra_build_options={}):
    """
    Create build settings for staging and PR
    @param build_context - Docker build context, string
    @param registry_path - Container Registry path, string
    @param extra_build_options - extra build options, dict
    @return build settings, dict
    """
    defaults = {
        "registry": "registry.digitalocean.com",
        "repo": "registry.digitalocean.com/brighteon-registry/%s" % registry_path,
        "dockerfile": "%s/Dockerfile" % build_context,
        "context": build_context,
        "cache_from": [ "registry.digitalocean.com/brighteon-registry/%s:${DRONE_COMMIT_BRANCH}" % registry_path ],
        "config": {
            "from_secret": "docker_config"
        },
        "tags": IMAGE_BUILD_TAGS,
    }
    return dict(defaults, **extra_build_options)

def _deploy_steps(environment, build_context, registry_path, predeployment_steps=[], postdeployment_steps=[]):
    """
    Generate deployment steps for staging and PR
    
    @param environment - a name of environment, string
    @param build_context - Docker build context, string
    @param registry_path - Container Registry path, string
    @param predeployment_steps - commands which must be executed before chart deployment, list
    @param postdeployment_steps - commands which must be executed after chart deployment, list
    @return staging deployment steps, dict 
    """
    kube_settings = STAGING_KUBE_SETTINGS
    namespace = "brighteon"
    triggers = environment
    if environment == "pr":
        namespace = 'pr-"${DRONE_PULL_REQUEST}"'
    elif environment == "preproduction":
        namespace = environment
    elif environment == "production":
        kube_settings = PRODUCTION_KUBE_SETTINGS
        triggers = "deploy_" + environment
    defaults = {
        "image": "alpine/helm",
        "environment": _generate_env_from_secrets(kube_settings),
        "commands": [
            """ helm --kube-apiserver="$${KUBE_API_SERVER}" --kube-token="$${KUBE_TOKEN}" -n %s upgrade --install --debug %s helm/chart -f %s/helm/%s-values.yaml --set image.tag="${DRONE_COMMIT}" """ %  (namespace, registry_path, build_context, environment),
        ],
        "when": _generate_pipeline_triggers(*PIPELINE_TRIGGERS[triggers]),
    }
    if predeployment_steps:
        defaults["commands"] = predeployment_steps + defaults["commands"]
    if postdeployment_steps:
        defaults["commands"] += postdeployment_steps
    return defaults


def _param_build_settings_frontend(environment, build_context, registry_path):
    """
    Create build settings for frontend services
    @param environment - a name of environment, string
    @param build_context - Docker build context, string
    @param registry_path - Container Registry path, string
    @return step with docker build and push of frontend services, dict
    """
    if environment == "production":
        defaults = {
            "settings": _build_setting(build_context, registry_path, extra_build_options={
                "build_args": [
                    "API_URL=https://www.brighteon.com",
                    "APP_URL=https://www.brighteon.com",
                    "AUTH_AUDIENCE=https://brighteon.com",
                    "AUTH_URL=https://auth.brighteon.com",
                    "STRIPE_PUBLISHABLE_KEY=pk_live_JVjMJSBVRy4ma8luZsdvQkwD"
                ]
            }),
            "when": _generate_pipeline_triggers(*PIPELINE_TRIGGERS["build_" + environment]),
        }
        if registry_path == "streaming":
            defaults["settings"]["build_args"].append("APP_DOMAIN=stream.printyourfood.com")
    
    elif environment == "preproduction":
        defaults = {
            "settings": _build_setting(build_context, registry_path, extra_build_options={
                "build_args": [
                    "API_URL=https://preproduction.printyourfood.com",
                    "APP_URL=https://preproduction.printyourfood.com",
                    "APP_DOMAIN=preproduction.printyourfood.com",
                    "AUTH_AUDIENCE=https://preproduction.printyourfood.com",
                    "AUTH_URL=https://auth-preproduction.printyourfood.com",
                    "STRIPE_PUBLISHABLE_KEY=pk_live_JVjMJSBVRy4ma8luZsdvQkwD"
                ]
            }),
            "when": _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment]),
        }

    elif environment == "pr":
        defaults = {
            "settings": _build_setting(build_context, registry_path, extra_build_options={
                "build_args": [
                    "AUTH_AUDIENCE=https://brighteon.com",
                    "AUTH_CLIENT_ID=7c9e9d6dd1dc62295aafd17fcecc7d9",
                    "STRIPE_PUBLISHABLE_KEY=pk_test_EfDG0yxSU200SSU1shcUnTFi00BqQncLwo",
                ],
                "build_args_from_env": [
                    "API_URL",
                    "APP_URL",
                    "APP_DOMAIN",
                    "AUTH_URL",
                ]            
            }),
            "environment": {
                "API_URL": "https://pr-${DRONE_PULL_REQUEST}.printyourfood.com",
                "APP_URL": "https://pr-${DRONE_PULL_REQUEST}.printyourfood.com",
                "APP_DOMAIN": "pr-${DRONE_PULL_REQUEST}.printyourfood.com" if registry_path == "frontend" else "stream-pr-${DRONE_PULL_REQUEST}.printyourfood.com",
                "AUTH_URL": "https://auth-${DRONE_PULL_REQUEST}.printyourfood.com",                    
            },
            "when": _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment]),
        }

    else:
        defaults = {
            "settings": _build_setting(build_context, registry_path, extra_build_options={
                "build_args": [
                    "API_URL=https://staging.printyourfood.com",
                    "APP_URL=https://staging.printyourfood.com",
                    "APP_DOMAIN=stream.printyourfood.com",
                    "AUTH_AUDIENCE=https://brighteon.com",
                    "AUTH_URL=https://auth.printyourfood.com",
                    "AUTH_CLIENT_ID=7c9e9d6dd1dc62295aafd17fcecc7d9",
                    "STRIPE_PUBLISHABLE_KEY=pk_test_EfDG0yxSU200SSU1shcUnTFi00BqQncLwo",
                ],
            }),
            "when": _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment]),
        }
    return defaults


def _param_build_settings_backend(environment, build_context, registry_path):
    """
    Create build settings for backend services
    @param environment - a name of environment, string
    @param build_context - Docker build context, string
    @param registry_path - Container Registry path, string
    @return step with docker build and push of backend services, dict
    """
    if environment == "production":
        environment = "build_production"
    defaults = {
        "settings": _build_setting(build_context, registry_path),
        "when": _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment]),
    }
    return defaults

def _param_deploy_settings(environment, build_context, registry_path):
    """
    Create deploy settings
    @param environment - a name of environment, string
    @param build_context - Docker build context, string
    @param registry_path - Container Registry path, string
    @return deploy settings, dict
    """
    if environment == "pr":
        defaults = _deploy_steps(environment, build_context, registry_path, predeployment_steps=[
            'sed -i "s%PR_NUMBER%$${DRONE_PULL_REQUEST}%g" ' + build_context+'/helm/pr-values.yaml',
        ])
    else:
        defaults = _deploy_steps(environment, build_context, registry_path)
    return defaults


def _pipeline_generic_skeleton(name, environment=""):
    """
    Generate base pipeline skeleton
    @param name - a pipeline name, string
    @environment - environment name, string
    @return pipeline, dict
    """
    if environment != "":
        environment = " - " + environment
    pipeline = {
        "kind": "pipeline",
        "type" : "kubernetes",
        "name": name + environment,
        "platform": {
            "os": "linux",
            "arch": "amd64"
        },
        "steps": [],
    }
    return pipeline


def prepare_dedicated_environment():
    """
    Prepare dedicated environment
    @return a pipeline that prepares dedicated environment, list
    """
    pipeline = _pipeline_generic_skeleton("Prepare dedicated environment")
    pipeline ["steps"] = [
        {
            "name": "Clone secrets repository",
            "image": "alpine/git",
            "pull": "if-not-exists",
            "commands": [ "git clone https://github.com/webseedcom/brighteon-k8s-secrets.git" ]
        },
        {
            "name": "Create the environment",
            "image": "bitsbeats/drone-helm3:0.1.24",
            "pull": "if-not-exists",
            "settings": _generate_env_from_secrets(STAGING_KUBE_SETTINGS),
            "commands": [
                'kubectl create namespace pr-$${DRONE_PULL_REQUEST} | true',
                # replace the values in templates of secrets
                'sed -i "s%PR_NUMBER%$DRONE_PULL_REQUEST%g" brighteon-k8s-secrets/pr/*.yml',
                'sed -i "s%PR_NUMBER%$DRONE_PULL_REQUEST%g" brighteon-k8s-secrets/pr/*.env',
                'sed -i "s%PR_NUMBER%$DRONE_PULL_REQUEST%g" brighteon-k8s-secrets/pr/comments/*.json',
                # apply the secrets
                'kubectl -n pr-$${DRONE_PULL_REQUEST} apply -f brighteon-k8s-secrets/pr/registry.yml',
                "kubectl apply -k brighteon-k8s-secrets/pr/"
            ]
        },
        {
            "name": "Create Brighteon DB",
            "image": "jbergknoff/postgresql-client",
            "pull": "if-not-exists",
            "environment": _generate_env_from_secrets(STAGING_POSTGRES_SECRETS),
            "commands": [
                # somewhat elegant way to skip new DB setup if the DB already exists
                'psql "$${PG_CONN_STRING_ADMIN}/postgres" -lqt | awk "{print $1}" | grep -qw "comments$${DRONE_PULL_REQUEST}" && exit 0',
                # create the DB; note that PG_CONN_STRING_ADMIN has admin credentials
                'psql "$${PG_CONN_STRING_ADMIN}/postgres" -c "CREATE DATABASE pr$${DRONE_PULL_REQUEST};"',
                # import it from staging DB: note that PG_CONN_STRING must not include the DB name!
                'pg_dump "$${PG_CONN_STRING}/brighteon" | psql "$${PG_CONN_STRING}/pr$${DRONE_PULL_REQUEST}"'
            ]
        },
        {
            "name": "Create Comments DB",
            "image": "jbergknoff/postgresql-client",
            "pull": "if-not-exists",
            "environment": _generate_env_from_secrets(STAGING_POSTGRES_SECRETS),
            "commands": [
                'if psql "$${PG_CONN_STRING_ADMIN}/postgres" -lqt | awk "{print $1}" | grep -qw "comments$${DRONE_PULL_REQUEST}"; then exit 0; fi',
                'psql "$${PG_CONN_STRING_ADMIN}/postgres" -c "CREATE DATABASE comments$${DRONE_PULL_REQUEST};"',
                'pg_dump "$${PG_CONN_STRING}/comments" | psql "$${PG_CONN_STRING}/comments$${DRONE_PULL_REQUEST}"'                    
            ]
        },
        {
            "name": "Create dedicated Redis instance",
            "image": "alpine/helm",
            "pull": "if-not-exists",
            "environment": _generate_env_from_secrets(STAGING_KUBE_SETTINGS),
            "commands": [
                'if helm --kube-apiserver="$${KUBE_API_SERVER}" --kube-token="$${KUBE_TOKEN}" list -n pr-$${DRONE_PULL_REQUEST} | grep -qw redis; then exit 0; fi',
                'helm repo add bitnami https://charts.bitnami.com/bitnami',
                """ helm --kube-apiserver="$${KUBE_API_SERVER}" --kube-token="$${KUBE_TOKEN}" -n pr-$${DRONE_PULL_REQUEST} upgrade --install redis bitnami/redis -f ./redis-values.yaml """,
            ],
        }
    ]
    pipeline["image_pull_secrets"] = [ "docker_config" ]
    pipeline["trigger"] = _generate_pipeline_triggers(*PIPELINE_TRIGGERS["pr"])
    return pipeline


def pr_cleanup_cron_job():
    """
    Create cron job to cleanop PR envs
    @return PR cleanup cron job pipeline, dict
    """
    pipeline = _pipeline_generic_skeleton("Cleanup dedicated environment cron job")
    pipeline["steps"] = [
        {
            "name": "PR env cleanup cron job",
            "image": "registry.digitalocean.com/brighteon-registry/pr-cleanup:latest",
            "environment": {
                "GITHUB_TOKEN": {
                    "from_secret": "github_token"
                },
                "PG_CONN_STRING_ADMIN": {
                    "from_secret": "dh_stg_pg_conn_string_admin"
                },
                "DIGITALOCEAN_ACCESS_TOKEN": {
                    "from_secret": "dh_stg_access_token"
                }
            }
        }
    ]
    pipeline["image_pull_secrets"] = ["docker_config"]
    pipeline["trigger"] = {
        "event": ["cron"],
        "cron": ["pr-cleanup"],
        "branch": {
            "exclude": ["master"]
        }
    }
    return pipeline


def pr_cleanup():
    """
    Generate manual PR cleanup pipeline
    @return a pipeline that deletes specific PR, dict
    """
    pipeline = _pipeline_generic_skeleton("Cleanup dedicated environment")
    pipeline["steps"] = [
        {
            "name": "Delete the environment",
            "image": "bitsbeats/drone-helm3:0.1.24",
            "pull": "if-not-exists",
            "settings": _generate_env_from_secrets(STAGING_KUBE_SETTINGS),
            "commands": [
                'echo "pr-$${PR_NUMBER}" | grep -v "^brighteon$"',
                'kubectl delete namespace "pr-$${PR_NUMBER}"'
            ]
        },
        {
            "name": "Delete PostgreSQL DBs",
            "image": "jbergknoff/postgresql-client",
            "pull": "if-not-exists",
            "environment": _generate_env_from_secrets(STAGING_POSTGRES_SECRETS),
            "commands": [
                """ echo -e "\\set AUTOCOMMIT on\\nSELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = "pr$${PR_NUMBER}"; DROP DATABASE pr$${PR_NUMBER};" | psql "$${PG_CONN_STRING_ADMIN}/brighteon" """,
                """ echo -e "\\set AUTOCOMMIT on\\nSELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = "comments$${PR_NUMBER}"; DROP DATABASE comments$${PR_NUMBER};" | psql "$${PG_CONN_STRING_ADMIN}/brighteon" """
            ]
        }
    ]
    pipeline["image_pull_secrets"] = [ "docker_config" ]
    pipeline["trigger"] = _generate_pipeline_triggers(["master",], ["promote",], "exclude", "include", ["cleanup"])
    return pipeline


def _generate_frontend_pipeline(microservice, environment, build_context):
    """
    Generate a pipeline that builds and deploy Brighteon Frontend parts
    @param microservice - microservice name that is going to be deployed, string
    @param environment - a name of environment, string
    @param build_context - Docker build context, string
    @return a pipeline which builds and deploys frontend service of Brighteon, dict
    """
    pipeline = _pipeline_generic_skeleton(microservice, environment)
    purge_cache = {}
    build_step = dict({
        "name": "Docker image - %s %s" % (microservice, environment),
        "image": "plugins/docker",
        "pull": "if-not-exists",
    }, **_param_build_settings_frontend(environment, build_context, microservice))
    if environment != "pr":
        purge_cache = dict({
            "name": "Purge CloudFlare cache - %s" % environment,
            "image": "jetrails/drone-cloudflare-caching",
            "pull": "if-not-exists",
        }, **_purge_cloudflare_cache(environment))
    deploy_step = dict({
        "name": "Deploy %s to %s" % (microservice, environment),
        "pull": "if-not-present",
    }, **_param_deploy_settings(environment, build_context, microservice))
    pipeline["steps"].append(build_step)
    pipeline["steps"].append(deploy_step)
    if purge_cache:
        pipeline["steps"].append(purge_cache)
    pipeline["trigger"] = _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment])
    return pipeline


def _generate_backend_pipeline(microservice, environment, build_context):
    """
    Generate a pipeline that builds and deploy Brighteon Backend parts
    
    @param microservice - microservice name that is going to be deployed, string
    @param environment - a name of environment, string
    @param build_context - Docker build context, string
    @return a pipeline which builds and deploys backend service of Brighteon, dict
    """
    pipeline = _pipeline_generic_skeleton(microservice, environment)
    build_step = dict({
        "name": "Docker image - %s %s" % (microservice, environment),
        "image": "plugins/docker",
        "pull": "if-not-exists",
    }, **_param_build_settings_backend(environment, build_context, microservice))
    deploy_step = dict({
        "name": "Deploy %s to %s" % (microservice, environment),
        "pull": "if-not-present",
    }, **_param_deploy_settings(environment, build_context, microservice))
    pipeline["steps"].append(build_step)
    pipeline["steps"].append(deploy_step)
    pipeline["image_pull_secrets"] = [ "docker_config" ]
    pipeline["trigger"] = _generate_pipeline_triggers(*PIPELINE_TRIGGERS[environment])
    if environment == "pr":
        pipeline["depends_on"] = [ "Prepare dedicated environment" ]
    return pipeline


def main(ctx):
    pipelines = []
    pipelines.append(prepare_dedicated_environment())
    pipelines.append(pr_cleanup_cron_job())
    #pipelines.append(pr_cleanup())
    for environment in ENVIRONMENTS:
        frontend_pipelines = [
            _generate_frontend_pipeline(microservice, environment, MICROSERVICES_FRONTEND[microservice]) for microservice in MICROSERVICES_FRONTEND
        ]
        backend_pipelines = [
            _generate_backend_pipeline(microservice, environment, MICROSERVICES_BACKEND[microservice]) for microservice in MICROSERVICES_BACKEND
        ]
        pipelines += frontend_pipelines
        pipelines += backend_pipelines
    return pipelines
