*** Settings ***
Library         REST
Library         Collections
Library         json
Library         String
Library         ../lib/Tools.py

*** Variables ***
${STATUS_CODE_OK}                             200
${HOST}                                       localhost
${PORT_DEVICE_VIRTUAL}                        49990
${PORT_METADATA}                              48081
${BASE_URL_DEVICE_VIRTUAL}                    http://${HOST}:${PORT_DEVICE_VIRTUAL}/api/v1
${BASE_URL_METADATA}                          http://${HOST}:${PORT_METADATA}/api/v1
${PATH_PING}                                  ping
${PATH_GET_DEVICE_PROFILE}                    deviceprofile/name
${PATH_GET_DEVICE}                            device/name
${PATH_PUT_DEVICE}                            device/name

*** Keywords ***
Send ping request
    ${url} =    Create url    ${BASE_URL_DEVICE_VIRTUAL}    ${PATH_PING}
    Send get request    ${url}

Send get request
    [Arguments]    ${url}
    ${RESPONSE} =    GET    ${url}    headers={ "Accept": "text/plain" }
    Set Test Variable    ${RESPONSE}

Send put request
    [Arguments]    ${url}    ${body}
    ${RESPONSE} =    PUT    ${url}    body=${body}    headers={ "Accept": "application/json" }
    Set Test Variable    ${RESPONSE}

Create url
    [Arguments]    @{args}
    ${url} =    Catenate    SEPARATOR=/    @{args}
    [Return]  ${url}

Response status is ok
    Should be true    ${RESPONSE["status"]} == ${STATUS_CODE_OK}

Response time should be less than "${acceptable_value}" milliseconds
    Should be true    ${RESPONSE["seconds"]} < ${acceptable_value}

Response should have header "${content_type}"
    Should contain    ${RESPONSE["headers"]}    ${content_type}

Response text should include version number "${version_number}"
    Should contain    ${RESPONSE["body"]}    ${version_number}

Get device profile "${profile_name}"
    ${url} =    Create url    ${BASE_URL_METADATA}    ${PATH_GET_DEVICE_PROFILE}    ${profile_name}
    Send get request    ${url}

Content type is "${expected_type}"
    Should be equal as strings    ${RESPONSE["headers"]["Content-Type"]}    ${expected_type}

Response body is json format
    ${string} =    Json.Dumps    ${RESPONSE["body"]}
    Should be valid json    ${string}

Device profile name is "${expected_device_profile_name}"
    ${name} =    Get json value    ${RESPONSE["body"]}    /name
    Should be equal as strings    ${name}    ${expected_device_profile_name}

Get device "${device_name}"
    ${url} =    Create url    ${BASE_URL_METADATA}    ${PATH_GET_DEVICE}    ${device_name}
    Send get request    ${url}

Device name is "${expected_device_name}"
    ${name} =    Get json value    ${RESPONSE["body"]}    /name
    Should be equal as strings    ${name}    ${expected_device_name}

Set "${resource}" of "${device}" to "${value}"
    ${url} =    Create url    ${BASE_URL_DEVICE_VIRTUAL}    ${PATH_PUT_DEVICE}    ${device}    ${resource}
    ${dict} =    Create Dictionary    ${resource}=${value}
    ${body} =    Json.Dumps    ${dict}
    Send put request    ${url}    ${body}

"${resource}" of "${device}" should be "${expected_value}"
    ${url} =    Create url    ${BASE_URL_DEVICE_VIRTUAL}    ${PATH_GET_DEVICE}    ${device}    ${resource}
    Send get request    ${url}
    ${value} =    Get json value    ${RESPONSE["body"]}    /readings/0/value
    Should be equal    ${value}    ${expected_value}
