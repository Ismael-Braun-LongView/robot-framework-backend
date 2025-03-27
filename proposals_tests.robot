*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource   proposals_keywords.resource
Library    PerformanceMetrics.py    WITH NAME    Perf

*** Test Cases ***
Fazer Login no Sistema
    Logar

Testar a performace do endpoint de propostas
    [Documentation]    Chamar o endpoint das propostas sem filtro e medir o tempo de resposta
    ${response}    ${duration}=    Perf.Measure Execution   Procurar proposta
    ${stats}=    Perf.Get Timing Stats    Procurar proposta
    ${avg}=    Set Variable    ${stats['average']}
    ${avg_formatted}=    Evaluate    "%.3f" % ${avg}
    Log    Tempo médio: ${avg_formatted}s

Procurar Proposta por CPF
    ${results}=    Procurar proposta    cpf=553.309.400-87
    ${json}=    Set Variable    ${results.json()}
    Should Be True    ${json['count']} > 0
    Log    ${json}

Procurar Proposta por CPF inválido
   ${results}=    Procurar proposta    cpf=888.888.888-80
    ${json}=    Set Variable    ${results.json()}
    Should Be True    ${json['count']} <= 0
    Log    ${json}

Criar nova proposta
    ${proposal_data}=    Criar Dicionário de Proposta Valida

    # esse response retorna o json da proposta caso ela for criada
    # caso contrário, retorna um erro definido dentro da classe ProposalsLibrary e o teste falha
    ${response}=    Criar Proposta    ${proposal_data}

    ${created_proposal}=    Set Variable    ${response.json()}

    Validar Estrutura da Proposta    ${created_proposal}

    Log    Proposta criada com sucesso: ID ${created_proposal['id']}

Tentar criar proposta com Tabela de Taxa inválida
    ${proposal_data}=    Criar Dicionário de Proposta Valida
    Set To Dictionary    ${proposal_data}    interest_rate_general=111111

    ${response}=    Criar Proposta    ${proposal_data}
    
    # validações
    Should Be Equal As Strings    ${response.status_code}    400
    Dictionary Should Contain Key    ${response.json()}    interest_rate_general
    Should Be Equal As Strings    ${response.json()['interest_rate_general'][0]}    
    ...    Pk inválido "111111" - objeto não existe.