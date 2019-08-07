*** Settings ***
Library         ../lib/EdgeX.py
Resource        resource.robot
Suite Setup     Deploy EdgeX
Suite Teardown  Shutdown EdgeX

*** Variables ***
${DEVICE_PROFILE_BOOL}     Random-Boolean-Device
${DEVICE_PROFILE_INT}      Random-Integer-Device
${DEVICE_PROFILE_UINT}     Random-UnsignedInteger-Device
${DEVICE_PROFILE_FLOAT}    Random-Float-Device
${DEVICE_BOOL}             Random-Boolean-Device
${DEVICE_INT}              Random-Integer-Device
${DEVICE_UINT}             Random-UnsignedInteger-Device
${DEVICE_FLOAT}            Random-Float-Device

*** Test Cases ***
Health check
    Given send ping request
    When response status is ok
    Then response time should be less than "600" milliseconds
    And response should have header "Content-Type"
    And response text should include version number "1.0.0"

Device profile existence check
    [Template]    Device profile should exist in metadata
    ${DEVICE_PROFILE_BOOL}
    ${DEVICE_PROFILE_INT}
    ${DEVICE_PROFILE_UINT}
    ${DEVICE_PROFILE_FLOAT}

Device existence check
    [Template]    Device should exist in metadata
    ${DEVICE_BOOL}
    ${DEVICE_INT}
    ${DEVICE_UINT}
    ${DEVICE_FLOAT}

Put value testing
    Given set "RandomValue_Int8" of "${device_int}" to "66"
    When response status is ok
    Then "RandomValue_Int8" of "${device_int}" should be "66"

*** Keywords ***
Device profile should exist in metadata
    [Arguments]    ${device_profile_name}
    Given get device profile "${device_profile_name}"
    When response status is ok
    Then response time should be less than "600" milliseconds
    And response should have header "Content-Type"
    And content type is "application/json"
    And response body is json format
    And device profile name is "${device_profile_name}"

Device should exist in metadata
    [Arguments]    ${device_name}
    Given get device "${device_name}"
    When response status is ok
    Then response time should be less than "600" milliseconds
    And response should have header "Content-Type"
    And content type is "application/json"
    And response body is json format
    And device name is "${device_name}"

