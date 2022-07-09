*** Settings ***
Documentation    certification level 2
Library    RPA.Browser
Library    RPA.Archive
Library    RPA.PDF
Library    RPA.Robocorp.Vault
Library    Collections
Library    RPA.Tables

*** Tasks ***
start
    init orders

archive receipts
    archive    ${CURDIR}${/}output    receipts
*** Keywords ***
init orders
    download csv    https://robotsparebinindustries.com/orders.csv
    ${url}=    Get Secret    link
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    ${file}=    Read csv file
    FOR    ${row}    IN RANGE    0    2    1
        Log To Console    ${file[${row}]}
        Click Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
        Set Suite Variable    ${ORDER}    '${file[${row}][${0}]}'
        select head    ${file[${row}][${1}]}
        Select body    ${file[${row}][${2}]}
        Enter legs    ${file[${row}][${3}]}
        Enter address    ${file[${row}][${4}]}
        Preview and copy robot
        click order wait for success
    END


Read csv file
    ${file}=    Read table from CSV    ${CURDIR}${/}Input/orders.csv    ${True}    delimiters=,
    RETURN    ${file}

select head
    [Arguments]    ${value}
    Select From List By Value    //*[@id="head"]    ${value}

select body    
    [Arguments]    ${value}
    ${xpath}=    Catenate    SEPARATOR=    //*[@id="root"]/div/div[1]/div/div[1]/form/div[2]/div/div[contains(@class, 'radio form-check')]/label[@for='id-body-${value}']
    Click Element    ${xpath}

Enter legs
    [Arguments]    ${value}
    Input Text    //*[@placeholder='Enter the part number for the legs']    ${value}

Enter address
    [Arguments]    ${value}
    Input Text    id:address    ${value}

Preview and copy robot
    Click Element    id:preview
    Sleep    2
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output/ss/${ORDER}.png

click order wait for success
    Wait Until Keyword Succeeds    1 min    2s    submit

submit
    Click Element    id:order
    ${visible}=    Element Should Be Visible    //*[@id="receipt"]    Error
    Log    ${visible}
    IF     ${visible} != 'Error'
        ${html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML
        Html To Pdf    ${html}    ${CURDIR}${/}output/${ORDER}.pdf
         ${pdfdata}=    Create List 
         ...    ${CURDIR}${/}output/${ORDER}.pdf
         ...    ${CURDIR}${/}output/ss/${ORDER}.png
        Add Files To Pdf    ${pdfdata}    ${CURDIR}${/}output/${ORDER}.pdf
        Click Element    id:order-another
        Sleep    2
        RETURN    ${True}
    ELSE
        RETURN    ${False}        
    END

archive
    [Arguments]    ${loc}    ${zipname}
    Archive Folder With Zip    ${loc}    ${zipname}    ${True}

download csv
    [Arguments]    ${url}
    Set Download Directory    ${CURDIR}${/}Input
    Open Available Browser    ${url}
    Sleep    5
    [Teardown]    Close All Browsers