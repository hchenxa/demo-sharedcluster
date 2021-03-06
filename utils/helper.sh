#!/usr/bin/env bash

function get_supported_type_from_file() {
    # Used to get the supported type from the enviroment.json based on the acm version user selected.
    acm_version=$1
    supported_type=$(jq -r ".acm_versions[]|select(.version == $acm_version)|.envs[].type" config/environment.json)
    return $supported_type
}

function get_ocp_route_from_file() {
    # Used to get the ocp route address from the file
    cluster_type=$1
    acm_version=$2
    echo $(jq -r ".acm_versions[]|select(.version == $acm_version)|.envs[]|select(.type== "$cluster_type")|ocp_route" config/environment.json)
}

function get_acm_route_from_file() {
    # Used to get the acm route address from the file
    cluster_type=$1
    acm_version=$2
    echo $(jq -r ".acm_versions[]|select(.version == $acm_version)|.envs[]|select(.type== "$cluster_type")|acm_route" config/environment.json)   
}

function get_provider_type() {
    # Used to get the ocp cluster cloud provider, and the return value will be GCP, AWS and so on.
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        _provider_type=$(KUBECONFIG=env-context/customer/kubeconfig oc get infrastructures.config.openshift.io cluster -o jsonpath={.status.platform})
    else
        acm_version=$2
        _provider_type=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get infrastructures.config.openshift.io cluster -o jsonpath={.status.platform})
    fi
    echo ${_provider_type}
}

function get_acm_version() {
    # Used to get the acm version
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        acm_package=$(KUBECONFIG=env-context/customer/kubeconfig oc get csv --all-namespaces | grep advanced-cluster-management | awk '{print $2}')
    else
        acm_version=$2
        acm_package=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get csv --all-namespaces | grep advanced-cluster-management | awk '{print $2}')
    fi
    echo ${acm_package#*advanced-cluster-management.}
}

function get_installed_namespace() {
    # Used to get the acm installed namespace
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        _acm_installed_ns=$(KUBECONFIG=env-context/customer/kubeconfig oc get csv --all-namespaces | grep advanced-cluster-management | awk '{print $1}')
    else
        acm_version=$2
        _acm_installed_ns=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get csv --all-namespaces | grep advanced-cluster-management | awk '{print $1}')
    fi
    echo ${_acm_installed_ns}
}

function get_acm_console() {
    # Used to get the acm console
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        acm_console=$(KUBECONFIG=env-context/customer/kubeconfig oc get route --all-namespaces | grep multicloud-console | awk '{print $3}')
    else
        acm_version=$2
        acm_console=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get route --all-namespaces | grep multicloud-console | awk '{print $3}')
    fi
    echo ${acm_console}
}

function phase_version() {
    old_version=$1
    echo $old_version|awk -F '.' '{print $1$2}'
}

function phase_type() {
    # Used to translet the type to upper.
    old_type=$*
    echo $old_type|tr 'a-z' 'A-Z'
}

function get_basedomain() {
    # Used to get the cluster base domain
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        route_console=$(KUBECONFIG=env-context/customer/kubeconfig oc get route -n openshift-console console -o jsonpath={.spec.host})
    else
        acm_version=$2
        route_console=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get route -n openshift-console console -o jsonpath={.spec.host})
    fi
    echo ${route_console#*apps.}
}

function get_idprovider() {
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        _user_name=$(KUBECONFIG=env-context/customer/kubeconfig oc whoami)
        if [[ $_user_name == "kube:admin" ]]; then
            _idp=kubeadmin
        else
            _user_id=$(KUBECONFIG=env-context/customer/kubeconfig oc get users $_user_name -o jsonpath={.metadata.uid})
            _idp=$(KUBECONFIG=env-context/customer/kubeconfig oc get identities | grep $_user_id | awk '{print $2}')
        fi
    else
        acm_version=$2
        _user_name=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc whoami)
        if [[ $_user_name == "kube:admin" ]]; then
          _idp=kubeadmin
        else
        _user_id=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get users $_user_name -o jsonpath={.metadata.uid})
        _idp=$(KUBECONFIG=env-context/${cluster_type}-${acm_version}/kubeconfig oc get identities | grep $_user_id | awk '{print $2}')
        fi
    fi
    echo $_idp
}

function get_config_path() {
    cluster_type=$1
    if [[ $cluster_type == "customer" ]]; then
        echo "env-context/customer"
    else
        acm_version=$2
        echo "env-context/${cluster_type}-${acm_version}"
    fi
}
