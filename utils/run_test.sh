#!/usr/bin/env bash

function run_test() {

    _test_case=$1
    _timestamp=$2
    _env_type=$3
    if [[ $_env_type == "customer" ]]; then
        result_path="$(pwd)/results/${_timestamp}/${_env_type}"
        config_path="$(pwd)/env_context/${_env_type}"
    else
        _cluster_version=$4
        result_path="$(pwd)/results/${_timestamp}/${_env_type}_${_cluster_version}"
        config_path="$(pwd)/env_context/${_env_type}_${_cluster_version}"
    fi
    echo "Start the running $_test_case cases..."

    case $_test_case in
        "SEARCH")
            sudo $DOCKER run \
            --network host \
            --dns 8.8.8.8 \
            --dns 8.8.4.4 \
            -e BROWSER="chrome" \
            --volume ${config_path}/kubeconfig:/opt/.kube/config \
            --volume ${config_path}/imported_kubeconfig:/opt/.kube/import-kubeconfig \
            --volume ${config_path}/${_test_case}/options.yaml:/resources/options.yaml \
            --volume $result_path:/results \
            --name search-e2e-${env_type} \
            quay.io/open-cluster-management/search-e2e:$TEST_SNAPSHOT
            ;;
        "KUI")
            sudo $DOCKER run \
            --network host \
            --env BROWSER="firefox" \
            --volume ${config_path}/kubeconfig:/opt/.kube/config \
            --volume ${result_path}:/results \
            --volume ${config_path}/${_test_case}/options.yaml:/resources/options.yaml \
            --name kui-web-tests-${env_type} \
            quay.io/open-cluster-management/kui-web-terminal-tests:$TEST_SNAPSHOT
            ;;
        "GRC_UI")
            #(TODO)
            # sudo $DOCKER run \
            # --volume $result_path/results:/opt/app-root/src/grc-ui/test-output/e2e \
            # --volume $result_path/results-cypress:/opt/app-root/src/grc-ui/test-output/cypress \
            # --env OC_CLUSTER_URL="https://api.${HUB_BASEDOMAIN}:6443" \
            # --env OC_CLUSTER_PASS="${HUB_PASSWORD}" \
            # --env OC_CLUSTER_USER="${HUB_USERNAME}" \
            # --env RBAC_PASS="${RBAC_PASS}" \
            # --env CYPRESS_STANDALONE_TESTSUITE_EXECUTION=FALSE \
            # --env MANAGED_CLUSTER_NAME="import-${TRAVIS_BUILD_ID}" \
            # --name grc-ui-tests-${env_type}-${cluster_version} \
            # quay.io/open-cluster-management/grc-ui-tests:${TEST_SNAPSHOT}
            ;;
        "GRC_FRAMEWORK")
            #(TODO)
            # managed_cluster_name=$(cat env_context/${env_type}_${cluster_version}/managed_cluster_name)
            # sudo $DOCKER run \
            # --network host \
            # --volume $result_path/:/go/src/github.com/open-cluster-management/governance-policy-framework/test-output \
            # --volume $(pwd)/env_context/${env_type}_${cluster_version}/kubeconfig:/go/src/github.com/open-cluster-management/governance-policy-framework/kubeconfig_hub \
            # --volume $(pwd)/env_context/${env_type}_${cluster_version}/imported_kubeconfig:/go/src/github.com/open-cluster-management/governance-policy-framework/kubeconfig_managed \
            # --env MANAGED_CLUSTER_NAME="$managed_cluster_name" \
            # --name grc-policy-framework-tests-${env_type}-${cluster_version} \
            # quay.io/open-cluster-management/grc-policy-framework-tests:$TEST_SNAPSHOT
            ;;
        "CONSOLE_UI")
            #(TODO)
            ;;
        "CLUSTER_LIFECYCLE")
            ;;
        "APP_UI")
            ;;
        "APP_BACKEND")
            #(TODO)
            # sudo $DOCKER run \
            # --volume $result_path/:/opt/e2e/client/canary/results \
            # --volume $(pwd)/env_context/${env_type}_${cluster_version}/kubeconfig:/opt/e2e/default-kubeconfigs/hub \
            # --volume $(pwd)/env_context/${env_type}_${cluster_version}/imported_kubeconfig:/opt/e2e/default-kubeconfigs/import-kubeconfig \
            # --env KUBE_DIR=/opt/e2e/default-kubeconfigs \
            # --name app-backend-e2e-${env_type}-${cluster_version} \
            # quay.io/open-cluster-management/applifecycle-backend-e2e:${TEST_SNAPSHOT}
            ;;
        "OBSERVABILITY")
            sudo $DOCKER run \
            --net host \
            --volume ${result_path}:/results \
            --volume ${config_path}/kubeconfig:/opt/.kube/config \
            --volume ${config_path}/${_test_case}/resources:/resources \
            --name observability-e2e-test-${env_type} \
            --env SKIP_INSTALL_STEP=true \
            --env SKIP_UNINSTALL_STEP=true \
            quay.io/open-cluster-management/observability-e2e-test:${TEST_SNAPSHOT}
            ;;
    esac

}
