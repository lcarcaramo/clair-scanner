#!/bin/bash

set -e

export ANSI_YELLOW_BOLD="\e[1;33m"
export ANSI_GREEN="\e[32m"
export ANSI_YELLOW_BACKGROUND="\e[1;7;33m"
export ANSI_GREEN_BACKGROUND="\e[1;7;32m"
export ANSI_CYAN_BACKGROUND="\e[1;7;36m"
export ANSI_CYAN="\e[36m"
export ANSI_RESET="\e[0m"
export DOCKERFILE_TOP="**************************************** DOCKERFILE ******************************************"
export DOCKERFILE_BOTTOM="**********************************************************************************************"
export TEST_SUITE_START="**************************************** SMOKE TESTS *****************************************"
export TEST_SUITE_END="************************************** TEST SUCCESSFUL ***************************************"

# Pass in path to folder where Dockerfile lives
print_dockerfile () {
        echo -e "$ANSI_CYAN$DOCKERFILE_TOP\n$(<$1/Dockerfile)\n$ANSI_CYAN$DOCKERFILE_BOTTOM $ANSI_RESET\n"
}

# Pass in test case message
print_test_case () {
        echo -e "\n$ANSI_YELLOW_BOLD$1 $ANSI_RESET"
}

print_info () {
        echo -e "\n$ANSI_CYAN$1 $ANSI_RESET \n"
}

print_success () {
        echo -e "\n$ANSI_GREEN$1 $ANSI_RESET \n"

}

wait_until_ready () {
        export SECONDS=$1
        export SLEEP_INTERVAL=$(echo $SECONDS 50 | awk '{ print $1/$2 }')

        echo -e "\n${ANSI_CYAN}Waiting ${SECONDS} seconds until ready: ${ANSI_RESET}"

        for second in {1..50}
        do
                echo -ne "${ANSI_CYAN_BACKGROUND} ${ANSI_RESET}"
                sleep ${SLEEP_INTERVAL}
        done

        echo -e "${ANSI_CYAN} READY${ANSI_RESET}"
}


# Pass in path to folder where Dockerfile lives
build () {
        print_dockerfile $1
        docker build -t $1 $1
}

cleanup () {
        docker rmi $1
}

suite_start () {
        echo -e "\n$ANSI_YELLOW_BACKGROUND$TEST_SUITE_START$ANSI_RESET \n"
}

suite_end () {
        echo -e "\n$ANSI_GREEN_BACKGROUND$TEST_SUITE_END$ANSI_RESET \n"
}


suite_start
        print_test_case "It can scan local images:"
                print_info "Building Configured Clair image..."
                build "configured-clair"

                print_info "Starting Clair's PostgreSQL database..."
                docker run --name clair-db -e POSTGRES_PASSWORD=password -d quay.io/ibmz/postgres:13
                wait_until_ready 10

                print_info "Stating Clair..."
                docker run --name configured-clair --network container:clair-db -d "configured-clair" -config=/config/config.yaml

                print_info "Pulling \"quay.io/ibmz/openjdk:11.0.8\" so that we can scan it with Clair Scanner..."
                docker pull quay.io/ibmz/openjdk:11.0.8

                print_info "Scanning \"quay.io/ibmz/openjdk:11.0.8\" with Clair Scanner..."
                docker run --network container:configured-clair --rm -v /var/run/docker.sock:/var/run/docker.sock:ro \
                       quay.io/ibmz/clair-scanner:13.0 --threshold="Negligible" --clair="http://localhost:6060" quay.io/ibmz/openjdk:11.0.8

                print_success "Success! Local image \"quay.io/ibmz/openjkd:11.0.8\" was scanned."

                docker rm -f configured-clair
                docker rm -f clair-db
                cleanup "configured-clair"
suite_end
