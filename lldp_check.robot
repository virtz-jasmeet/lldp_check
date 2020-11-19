*** Settings ***
Documentation                  Check and validate lldp service and configuration
Library                        SSHLibrary
Suite Teardown                 Close All Connections


*** Variables ***
@{ALLHOSTS}=        10.189.153.69  10.189.153.70  10.189.153.71  10.189.153.72  10.189.153.73  10.189.153.74  10.189.153.75
@{CONTROLLERS}=     10.189.153.69  10.189.153.70  10.189.153.71
@{COMPUTES}=        10.189.153.72  10.189.153.73  10.189.153.74  10.189.153.75
${USERNAME}         root
${PASSWORD}         STRANGE-EXAMPLE-neither

*** Test Cases ***
Check LLDP service should be running
    [Documentation]			Check LLDP service should be running
    FOR  ${HOST}  IN  @{CONTROLLERS}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  systemctl list-units --type=service --all | grep -i lldpad.service | awk -F"lldpad.service" '{print $2}' | awk '{print $2}'
        Should Be Equal         ${output}  active
        close connection
    END

Check LLDP config should match
    [Documentation]			Check LLDP config should match
    FOR  ${HOST}  IN  @{CONTROLLERS}
        open connection		    ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        Put File                lldpConfig.config_data  /root  mode=0660
        SSHLibrary.File Should Exist   /root/lldpConfig.config_data
        ${output}=              execute command   diff -is /root/lldpConfig.config_data /usr/local/bin/lldpConfig
        Run Keyword And Continue On Failure     should contain    ${output}    identical
        execute command         rm -f /root/lldpConfig.config_data
        close connection
    END

*** Keywords ***
