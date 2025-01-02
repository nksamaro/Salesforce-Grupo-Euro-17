public class FormalizacaoRepository {
    
    public List<CodigoProtheus__c> buscarCodigosProtheusOportunidadeGanha(Id idBancoParceiro, Id idProduto){
        return [
            SELECT
                Id,
                Codigo__c,
                Filial__c,
                Filial__r.CodigoEmpresa__c,
                Filial__r.CodigoFilial__c,
                RecordType.Name
            FROM
                CodigoProtheus__c
            WHERE
                Ativo__c = true
            AND(
                (
                    RecordType.Name = 'Parceiro'
                AND
                    Conta__c != null
                AND
                    Conta__c =: idBancoParceiro
                )
                OR
                (
                    RecordType.Name = 'Produtos'
                AND
                    Produto__c != null
                AND
                    Produto__c =: idProduto
                )
            )
            ORDER BY
                LastModifiedDate DESC
        ];
    }

    public List<CodigoProtheus__c> buscarCodigosProtheusFiliaisContasIds(Set<String> setCodigosFiliais, Set<Id> setContasIds){
        return [
            SELECT
                Id,
                Codigo__c
            FROM
                CodigoProtheus__c
            WHERE
                Ativo__c = true
            AND
                RecordType.Name = 'Conta'
            AND
                Conta__c IN: setContasIds
            AND
                Filial__r.CodigoFilial__c IN: setCodigosFiliais
        ];
    }

    public CodigoProtheus__c buscarCodigoProtheusFilialContaId(String codigoFilial, Id contaId){
        List<CodigoProtheus__c> lstCodigosProtheus = this.buscarCodigosProtheusFiliaisContasIds(new Set<String>{ codigoFilial }, new Set<Id>{ contaId });
        return !lstCodigosProtheus.isEmpty() ? lstCodigosProtheus[0] : null;
    }

    public List<CodigoProtheus__c> buscarCodigosProtheusFiliaisRepresentantesIds(Set<String> setCodigosFiliais, Set<Id> setRepresentantesIds){
        return [
            SELECT
                Id,
                Codigo__c,
                Filial__c,
                Filial__r.CodigoEmpresa__c,
                Filial__r.CodigoFilial__c,
                Representante__c
            FROM
                CodigoProtheus__c
            WHERE
                Ativo__c = true
            AND
                RecordType.Name = 'Representante'
            AND
                Filial__r.CodigoFilial__c IN: setCodigosFiliais
            AND
                Representante__c IN: setRepresentantesIds
        ];
    }

    public CodigoProtheus__c buscarCodigoProtheusFilialRepresentanteId(String codigoFilial, Id representanteId){
        List<CodigoProtheus__c> lstCodigosProtheus = this.buscarCodigosProtheusFiliaisRepresentantesIds(new Set<String>{ codigoFilial }, new Set<Id>{ representanteId });
        return !lstCodigosProtheus.isEmpty() ? lstCodigosProtheus[0] : null;
    }

    public Contrato__c buscarContratoRelacionadoOportunidadeId(Id oportunidadeId){
        List<Contrato__c> lstContratos = buscarContratosRelacionadosOportunidadesIds(new Set<Id>{ oportunidadeId });
        return !lstContratos.isEmpty() ? lstContratos[0] : null;
    }

    public List<Contrato__c> buscarContratosRelacionadosOportunidadesIds(Set<Id> setOportunidadesIds){
        return [
            SELECT
                Id,
                Name
            FROM
                Contrato__c
            WHERE
                Oportunidade__c IN: setOportunidadesIds
            ORDER BY
                CreatedDate DESC
        ];
    }

    public Account buscarContaPorId(Id accountId){
        List<Account> lstContas = this.buscarContaPorSetId(new Set<Id>{ accountId });
        return !lstContas.isEmpty() ? lstContas[0] : null;
    }

    public List<Account> buscarContaPorSetId(Set<Id> setAccountId){
        return [
            SELECT
                Id,
                Email__c,
                PersonContactId
            FROM
                Account
            WHERE
                Id IN: setAccountId
        ];
    }

    public List<InformacoesFinanceirasOportunidade__c> buscarContratosInvestimentosPorId(Id opportunityId){
        return this.buscarContratosInvestimentosPorSetId(new Set<Id> { opportunityId });
    }

    public List<InformacoesFinanceirasOportunidade__c> buscarContratosInvestimentosPorSetId(Set<Id> setOportunidadesIds){
        return [
            SELECT
                Id,
                Contrato__r.Name,
                Contrato__r.PercentualPendente__c,
                Contrato__r.PercentualUtilizado__c,
                Contrato__r.ValorContrato__c,
                Utilizado__c
            FROM
                InformacoesFinanceirasOportunidade__c
            WHERE
                Oportunidade__c IN: setOportunidadesIds
            AND
                RecordTypeId =: Schema.SObjectType.InformacoesFinanceirasOportunidade__c.getRecordTypeInfosByDeveloperName().get('Garantia').getRecordTypeId()
        ];
    }

    public List<Quote> buscarDadosCotacoesOportunidadesIds(Set<Id> setIdOportunidade){
        return [
            SELECT
                Id,
                BancoParceiro__c,
                NProposta__c
            FROM
                Quote
            WHERE
                OpportunityId IN: setIdOportunidade
            AND
                NProposta__c != null
            AND
                Status = 'Contratado'
            ORDER BY
                LastModifiedDate DESC
        ];
    }

    public Quote buscarDadosCotacaoOportunidadeId(Id idOportunidade){
        List<Quote> listCotacao = buscarDadosCotacoesOportunidadesIds(new Set<Id>{ idOportunidade });
        return !listCotacao.isEmpty() ? listCotacao[0] : null;
    }

    public Opportunity buscarDadosOportunidadeGanha(Id oportunidadeId){
        return[
            SELECT
                Id,
                Account.BairroCobranca__c,
                Account.BillingAddress,
                Account.Celular__c,
                Account.ComplementoCobranca__c,
                Account.DataNascimento__c,
                Account.Documento__c,
                Account.EstadoCivil__c,
                Account.Name,
                Account.NumeroCobranca__c,
                Account.Phone,
                Account.RecordType.Name,
                Account.RG__c,
                AccountId,
                Banco__r.Documento__c,
                CreatedDate,
                DataAporte__c,
                DataFimContrato__c,
                Name,
                Periodo__c,
                PrazoOperacao__c,
                Produto__c,
                RecordType.DeveloperName,
                OwnerId,
                Taxa__c,
                UnidadeNegocio__c,
                ValorFinanciamento__c,
                ValorOportunidade__c,
                (
                    SELECT 
                        Id,
                        InformacesFinanceirasConta__r.Agencia__c,
                        InformacesFinanceirasConta__r.Conta__c,
                        InformacesFinanceirasConta__r.InstituicaoFinaneira__c,
                        PercentualInvestimento__c,
                        TipoConta__c,
                        TipoTransacao__c
                    FROM
                        InformacoesFinanceirasOportunidade__r
                    WHERE
                        RecordType.DeveloperName = 'DadosBancarios'
                ),
                (
                    SELECT
                        Id,
                        Nacionalidade__c,
                        OrgaoEmissor__c
                    FROM
                        Contrato__r
                    ORDER BY
                        CreatedDate DESC
                )
            FROM
                Opportunity
            WHERE
                Id =: oportunidadeId
        ];
    }

    public Endpoint__mdt buscarEndpointPorNomeAPI(String nomeAPI){
        return [
            SELECT
                Id,
                CredencialNomeada__c
            FROM
                Endpoint__mdt
            WHERE
                DeveloperName =: nomeAPI
            LIMIT 1
        ];
    }

    public Integracao__mdt buscarIntegracaoPorNomeAPI(String nomeAPI){
        return [
            SELECT
                Id,
                Path__c
            FROM
                Integracao__mdt
            WHERE
                DeveloperName =: nomeAPI
            LIMIT 1
        ];
    }

    public Lead buscarLeadPorId(Id leadId){
        List<Lead> lstLeads = this.buscarLeadPorSetId(new Set<Id>{leadId});
        return !lstLeads.isEmpty() ? lstLeads[0] : null;
    }

    public List<Lead> buscarLeadPorSetId(Set<Id> setLeadId){
        return [
            SELECT
                Id,
                Email
            FROM
                Lead
            WHERE
                Id IN: setLeadId
        ];
    }

    public List<EmailTemplate> buscarTemplateEmailPorNome(String nomeTemplate){
        return [
            SELECT
                Id,
                HtmlValue,
                Subject
            FROM
                EmailTemplate
            WHERE
                Name =: nomeTemplate
        ];
    }

    public List<TimeRelacionamento__c> buscarTimesRelacionamentoOportunidadeId(Id oportunidadeId){
        return [
            SELECT
                Id,
                Conta__c,
                DivisaoComissao__c,
                NomeGerente__c,
                RecordType.Name
            FROM
                TimeRelacionamento__c
            WHERE
                Oportunidade__c =: oportunidadeId
        ];
    }

    public FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse integrarOportunidadeGanhaProtheus(String body){
        Endpoint__mdt endpoint = buscarEndpointPorNomeAPI('Protheus');
        Integracao__mdt integracao = buscarIntegracaoPorNomeAPI('ProtheusIntegracaoOportunidade');
        String apiUrl = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;
        FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse oportunidadeResponse = new FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse();

        String accessToken = 'Bearer ' + CustomAuthenticationService.getToken();
        Map<String, String> headers = new Map<String, String> { 'Content-Type' => 'application/json', 'Authorization' => accessToken };
        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiUrl, 'POST', headers, body, 120000);

        if(response.getStatusCode() != 201 || !response.getBody()?.contains('PROPOSALCODE') || response.getBody()?.contains('error')){
            throw new HandledException(
                String.format('Http status: {0}\n | Erro: {1}', new List<String> {
                    String.valueOf(response.getStatusCode()),
                    response.getBody()})
            );
        } else
            oportunidadeResponse = (FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse) JSON.deserialize(response.getBody(), FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse.class);

        return oportunidadeResponse;
    }

    public List<FormalizacaoSchema.EuroSecutizadoraContratoResponse> retornarContratosEuroSecuritizadoraAPI(String cpf) {
        Endpoint__mdt endpoint = buscarEndpointPorNomeAPI('EuroSecuritizadora');
        Integracao__mdt integracao = buscarIntegracaoPorNomeAPI('EuroSecuritizadoraListarContratos');
        List<Object> lstParamsEndpoint = new List<Object>{ cpf };
        List<FormalizacaoSchema.EuroSecutizadoraContratoResponse> lstContratosCliente = new List<FormalizacaoSchema.EuroSecutizadoraContratoResponse>();

        String accessToken = 'Bearer ' + new CustomAuthenticationEuroSecuritizadora().getToken();
        String apiEndpoint = String.format('callout:' + endpoint.CredencialNomeada__c + integracao.Path__c, lstParamsEndpoint);
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json', 'Authorization' => accessToken};

        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiEndpoint, 'GET', headers, null, 15000);

        if(response.getStatusCode() == 200){
            String bodyFormat = response.getBody().replace('"number"', '"contractNumber"');
            lstContratosCliente = (List<FormalizacaoSchema.EuroSecutizadoraContratoResponse>) JSON.deserialize(bodyFormat, List<FormalizacaoSchema.EuroSecutizadoraContratoResponse>.class);
        } else {
            if(response.getStatusCode() == 404)
                throw new Formalizacao.FormalizacaoException('Não foram encontrados contratos disponíveis para este cliente.');
            else{
                throw new Formalizacao.FormalizacaoException(
                    String.format('Http status: {0}\n|Erro: {1}', new List<String> {
                        String.valueOf(response.getStatusCode()),
                        response.getBody()})
                );
            }
        }

        return lstContratosCliente;
    }

    public FormalizacaoSchema.SimularParcelasResponse retornarDadosSimulacaoCreditoFlowFinanceAPI(FormalizacaoSchema.SimularParcelasRequest spf) {
        Endpoint__mdt endpoint = buscarEndpointPorNomeAPI('SimularParcelasHost');
        Integracao__mdt integracao = buscarIntegracaoPorNomeAPI('SimularParcelasPath');
        String apiUrl = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;
        FormalizacaoSchema.SimularParcelasResponse simularParcelasRetornada = new FormalizacaoSchema.SimularParcelasResponse();

        String accessToken = 'Bearer ' + CustomAuthenticationSimularParcelas.getTokenParcelas();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json', 'Authorization' => accessToken};

        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiUrl, 'POST', headers, JSON.serialize(spf), 15000);

        if(response.getStatusCode() == 200) {
            simularParcelasRetornada = (FormalizacaoSchema.SimularParcelasResponse) System.JSON.deserialize(response.getBody(), FormalizacaoSchema.SimularParcelasResponse.class);
        } else {
            throw new HandledException(
                String.format('Http status: {0}\n|Erro: {1}', new List<String> {
                    String.valueOf(response.getStatusCode()),
                    response.getBody()})
            );
        }

        return simularParcelasRetornada;
    }

    public String retornarUrlDownloadEuroSecuritizadoraAPI(String cpf, String idContrato){
        Endpoint__mdt endpoint = buscarEndpointPorNomeAPI('EuroSecuritizadora');
        Integracao__mdt integracao = buscarIntegracaoPorNomeAPI('EuroSecuritizadoraDownloadExtrato');
        List<Object> lstParamsEndpoint = new List<Object>{ cpf, idContrato };
        String urlDownload;

        String accessToken = 'Bearer ' + new CustomAuthenticationEuroSecuritizadora().getToken();
        String apiEndpoint = String.format('callout:' + endpoint.CredencialNomeada__c + integracao.Path__c, lstParamsEndpoint);
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json', 'Authorization' => accessToken};

        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiEndpoint, 'GET', headers, null, 15000);

        if(response.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            urlDownload = String.valueOf(responseBody.get('url'));
        } else {
            if(response.getStatusCode() == 404)
                throw new Formalizacao.FormalizacaoException('Não foi possível encontrar o extrato consolidado relacionado a este contrato.');
            else{
                throw new Formalizacao.FormalizacaoException(
                    String.format('Http status: {0}\n|Erro: {1}', new List<String> {
                        String.valueOf(response.getStatusCode()),
                        response.getBody()})
                );
            }
        }

        return urlDownload;
    }

}