*** Settings ***
Documentation     Aqui podemos fazer as funções comumente usadas no teste case em sí.
Library    RequestsLibrary
Library    Collections
Library    AuthLibrary.py    ${BASE_URL}    WITH NAME    Auth
Library    ProposalLibrary.py    ${BASE_URL}    WITH NAME    Proposals

*** Variables ***
${BASE_URL}  http://localhost:8000
${CPFCNPJ}   seu_cnpj
${PASSWORD}  sua_senha
@{REQUIRED_FIELDS}
...    id
...    proposal_at
...    cpf
...    value
...    portion
...    client_name
...    product_company

*** Keywords ***
Logar
    [Documentation]    Faz login no backend usando o cnpj e senha
    ${response_token}=    Auth.Login    ${CPFCNPJ}    ${PASSWORD}
    Proposals.Set Token    ${response_token}

Procurar proposta
    [Arguments]    &{filters}
    ${results}=    Proposals.Procurar Proposta    &{filters}
    RETURN    ${results}

Criar Proposta
    [Documentation]    Cria uma nova proposta  
    [Arguments]    ${proposal_data}
    ${response}=    Proposals.Criar Proposta    ${proposal_data}
    RETURN    ${response}

Validar Estrutura da Proposta
    [Arguments]    ${proposal}
    # verifica campos obrigatórios
    FOR    ${field}    IN    @{REQUIRED_FIELDS}
        Dictionary Should Contain Key    ${proposal}    ${field}
    END
    
    # verifica formatos
    Validar CPF    ${proposal['cpf']}
    Validar Email    ${proposal['client_email']}
    Validar Telefone    ${proposal['client_phone']}

Validar CPF
    [Arguments]    ${cpf}
    Should Match Regexp    ${cpf}    ^\\d{11}$

Validar Email
    [Arguments]    ${email}
    Should Match Regexp    ${email}    ^[^@]+@[^@]+\\.[^@]+$

Validar Telefone
    [Arguments]    ${phone}
    Should Match Regexp    ${phone}    ^\\(\\d{2}\\)\\s\\d{4,5}-\\d{4}$

Criar Dicionário de Proposta Valida
    ${proposal_data}=    Create Dictionary
    ...    status=pending
    ...    proposal_at=2025-03-20T03:00:00.000Z
    ...    analyst_id=2352
    ...    cpf=12312312312
    ...    convenio=29
    ...    empcob=11
    ...    term=12
    ...    rate=1.2
    ...    value=10751.39
    ...    portion=999.99
    ...    iof=362.64
    ...    financed_amount=11114.03
    ...    client_value=10751.39
    ...    held_value=0
    ...    type=new
    ...    status_new=pending
    ...    new_pending_at=2025-03-20
    ...    agent_name=AHVA LTDA ME
    ...    agent=281
    ...    comission=1.8
    ...    grace_period=30
    ...    material_status_new=ok
    ...    material_at=2025-03-20T03:00:00.000Z
    ...    material_pending_at=${None}
    ...    esignature_platform=${None}
    ...    esignature_id=${None}
    ...    client_name=23213
    ...    material_status=ok
    ...    finished_at=${None}
    ...    credited_at=${None}
    ...    pending_at=2025-03-20T03:00:00.000Z
    ...    interest_rate_general=1
    ...    product_company=5
    ...    client_phone=(55) 63453-4543
    ...    client_email=sdfsdfsdfsdf@gmail.com

    RETURN    ${proposal_data}  