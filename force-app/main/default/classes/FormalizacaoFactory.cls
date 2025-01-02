public class FormalizacaoFactory {

    public String construirObjProtheusOportunidadeGanhaRequest(FormalizacaoSchema.ProtheusOportunidadeGanhaSalesforceRequest objSalesforceRequest){
        CodigoProtheus__c clienteProtheus = objSalesforceRequest.codigoProtheusConta;
        CodigoProtheus__c parceiroProtheus = objSalesforceRequest.mapCodigosProtheus.get('Parceiro');
        CodigoProtheus__c produtoProtheus = objSalesforceRequest.mapCodigosProtheus.get('Produtos');
        CodigoProtheus__c representanteProtheus = objSalesforceRequest.codigoProtheusRepresentante;
        List<InformacoesFinanceirasOportunidade__c> lstInfosFinanceirasOportunidade = objSalesforceRequest.lstInfosFinanceirasOportunidade;
        Map<Id, TimeRelacionamento__c> mapComissionados = objSalesforceRequest.mapComissionados;
        Map<Id, CodigoProtheus__c> mapIdComissionadosCodigoProtheus = objSalesforceRequest.mapIdComissionadosCodigoProtheus;
        Opportunity oportunidade = objSalesforceRequest.oportunidade;
        Quote cotacao = objSalesforceRequest.cotacao;
        String documentoFormat = Bdrs.Format.clearNumberFormatting(oportunidade.Account.Documento__c);
        String objOppGanhaRequestStr;
        String strObjOppGanha;

        Map<String, Object> mapObjOppGanha = new Map<String, Object> {
            'COMPANYID' => AtributoIntegracaoProtheus__mdt.getInstance('COMPANYID').ValorPadrao__c,
            'BRANCHID' => representanteProtheus.Filial__r.CodigoFilial__c,
            'DESCRIPTION' => oportunidade.Name.length() > 25 ? Util.removerAcentosCaracteres(oportunidade.Name.toUpperCase().substring(0, 25)) : Util.removerAcentosCaracteres(oportunidade.Name.toUpperCase()),
            'CUSTOMERCODE' => clienteProtheus.Codigo__c,
            'CUSTOMERSTORE' => oportunidade.Account.RecordType.Name == 'Empresa' ? '0001' : documentoFormat.substring(documentoFormat.length() - 3),
            'VENDORCODE' => representanteProtheus.Codigo__c,
            'VENDORPROCESS' => AtributoIntegracaoProtheus__mdt.getInstance('VENDORPROCESS').ValorPadrao__c,
            'STAGE' => AtributoIntegracaoProtheus__mdt.getInstance('STAGE').ValorPadrao__c,
            'DATEX' => String.valueOf(oportunidade.CreatedDate.date()).replace('-', ''),
            'TIMEX' => String.valueOf(oportunidade.CreatedDate.time()).substring(0, 5),
            'USER' => AtributoIntegracaoProtheus__mdt.getInstance('USER').ValorPadrao__c,
            'INITIALDATE' => String.valueOf(oportunidade.CreatedDate.date()).replace('-', ''),
            'FINALDATE' => String.valueOf(System.today()).replace('-', ''),
            'COIN' => AtributoIntegracaoProtheus__mdt.getInstance('COIN').ValorPadrao__c,
            'FCS' => AtributoIntegracaoProtheus__mdt.getInstance('FCS').ValorPadrao__c,
            'PRIORITY' => AtributoIntegracaoProtheus__mdt.getInstance('PRIORITY').ValorPadrao__c,
            'PRODUCT' => produtoProtheus.Codigo__c
        };

        List<FormalizacaoSchema.Comissao> lstComissionados = new List<FormalizacaoSchema.Comissao>();
        for(TimeRelacionamento__c comissionado : mapComissionados.values()){
            CodigoProtheus__c comissionadoProtheus = mapIdComissionadosCodigoProtheus.get(comissionado.Id);
            FormalizacaoSchema.Comissao comissao = new FormalizacaoSchema.Comissao();
            comissao.VENDORCODE = comissionadoProtheus.Codigo__c;
            comissao.PERCENT = comissionado.DivisaoComissao__c != null ? Integer.valueOf(comissionado.DivisaoComissao__c) : 0;
    
            lstComissionados.add(comissao);
        }

        mapObjOppGanha.put('COMISSION', lstComissionados);
        strObjOppGanha = JSON.serialize(mapObjOppGanha);

        switch on oportunidade.RecordType.DeveloperName {
            when 'Investimentos' {
                Contrato__c contrato = oportunidade.Contrato__r != null ? oportunidade.Contrato__r[0] : null;

                FormalizacaoSchema.ProtheusOportunidadeGanhaInvestimentosRequest objOppGanhaRequest = (FormalizacaoSchema.ProtheusOportunidadeGanhaInvestimentosRequest) JSON.deserialize(strObjOppGanha, FormalizacaoSchema.ProtheusOportunidadeGanhaInvestimentosRequest.class);
                objOppGanhaRequest.PROPOSALTYPE = 'I';
                objOppGanhaRequest.APPORT = String.valueOf(oportunidade.ValorOportunidade__c);
                objOppGanhaRequest.FEES = String.valueOf(oportunidade.Taxa__c);
                objOppGanhaRequest.INVESTMENTTIME = String.valueOf(oportunidade.PrazoOperacao__c);
                objOppGanhaRequest.INVESTMENTSTARTDATE = String.valueOf(oportunidade.DataAporte__c).replace('-', '');
                objOppGanhaRequest.INVESTMENTFINALDATE = String.valueOf(oportunidade.DataFimContrato__c).replace('-', '');
                objOppGanhaRequest.INVESTMENTRETURN = 'S';
                objOppGanhaRequest.MODALITY = oportunidade.Periodo__c == 'Mensal' ? 'M' : 'F';
                objOppGanhaRequest.NUMBEROFINSTALLMENTS = String.valueOf(oportunidade.PrazoOperacao__c);
                objOppGanhaRequest.SERIE = String.valueOf(Integer.valueOf(oportunidade.Taxa__c * 10));
                objOppGanhaRequest.BANKACCOUNTS = new List<FormalizacaoSchema.ContaBancaria>();
                objOppGanhaRequest.DEBENTUREOLDERS = new List<FormalizacaoSchema.Debenturista>();

                FormalizacaoSchema.Debenturista debenturista = new FormalizacaoSchema.Debenturista();
                debenturista.CUSTOMERCODE = clienteProtheus.Codigo__c;
                debenturista.CUSTOMERSTORE = oportunidade.Account.RecordType.Name == 'Empresa' ? '0001' : documentoFormat.substring(documentoFormat.length() - 3);
                debenturista.NAMECUSTOMER = Util.removerAcentosCaracteres(oportunidade.Account.Name.toUpperCase());
                debenturista.FEDERALIDCUSTOMER = Bdrs.Format.clearNumberFormatting(oportunidade.Account.Documento__c);
                debenturista.ADDRESS = Util.removerAcentosCaracteres(oportunidade.Account.BillingAddress.getStreet()?.toUpperCase());
                debenturista.NUMBERX = oportunidade.Account.NumeroCobranca__c;
                debenturista.COMPLEMENT = oportunidade.Account.ComplementoCobranca__c != null ? Util.removerAcentosCaracteres(oportunidade.Account.ComplementoCobranca__c.toUpperCase()) : '';
                debenturista.DISTRICT = Util.removerAcentosCaracteres(oportunidade.Account.BairroCobranca__c.toUpperCase());
                debenturista.ZIPCODE = oportunidade.Account.BillingAddress.getPostalCode() != null ? Bdrs.Format.clearNumberFormatting(oportunidade.Account.BillingAddress.getPostalCode()) : '';
                debenturista.CITY = Util.removerAcentosCaracteres(oportunidade.Account.BillingAddress.getCity()?.toUpperCase());
                debenturista.STATE = Util.removerAcentosCaracteres(oportunidade.Account.BillingAddress.getState()?.toUpperCase());
                debenturista.HOMEPHONE = oportunidade.Account.Phone != null ? oportunidade.Account.Phone : '';
                debenturista.COMMERCIALPHONE = '';
                debenturista.MOVELPHONE = oportunidade.Account.Celular__c != null ? oportunidade.Account.Celular__c : '';
                debenturista.MARITALSTATUS = oportunidade.Account.EstadoCivil__c != null ? Util.removerAcentosCaracteres(oportunidade.Account.EstadoCivil__c.toUpperCase()) : '';
                debenturista.SSNIDCUSTOMER = oportunidade.Account.RG__c != null ? oportunidade.Account.RG__c : '';
                debenturista.ISSUERSSNID = contrato?.OrgaoEmissor__c != null ? Util.removerAcentosCaracteres(contrato.OrgaoEmissor__c.toUpperCase()) : '';
                debenturista.BIRTHDATE = oportunidade.Account.DataNascimento__c != null ? String.valueOf(oportunidade.Account.DataNascimento__c).replace('-', '') : '';
                debenturista.NATIONALITY = contrato?.Nacionalidade__c != null ? Util.removerAcentosCaracteres(contrato.Nacionalidade__c.toUpperCase()) : '';
                objOppGanhaRequest.DEBENTUREOLDERS.add(debenturista);

                for(InformacoesFinanceirasOportunidade__c infoFinanceiraOportunidade : lstInfosFinanceirasOportunidade){
                    Double percentualInvestimento = infoFinanceiraOportunidade.PercentualInvestimento__c != null ? infoFinanceiraOportunidade.PercentualInvestimento__c : 0;
                    String tipoConta = '';
                    
                    switch on infoFinanceiraOportunidade.TipoConta__c {
                        when 'Conta corrente' {
                            tipoConta = 'C';
                        }

                        when 'Conta poupança' {
                            tipoConta = 'P';
                        }
                    }

                    FormalizacaoSchema.ContaBancaria contaBancaria = new FormalizacaoSchema.ContaBancaria();
                    contaBancaria.BANKCODECLIENT = '';
                    contaBancaria.BANKCODESTORE = '';
                    contaBancaria.BANKCODE = infoFinanceiraOportunidade.InformacesFinanceirasConta__r.InstituicaoFinaneira__c;
                    contaBancaria.ACCOUNTTYPE = tipoConta;
                    contaBancaria.BANKAGENCY = infoFinanceiraOportunidade.InformacesFinanceirasConta__r.Agencia__c;
                    contaBancaria.BANKACCOUNT = infoFinanceiraOportunidade.InformacesFinanceirasConta__r.Conta__c;
                    contaBancaria.CUSTOMERCODEOWNER = clienteProtheus.Codigo__c;
                    contaBancaria.CUSTOMERSTOREOWNER = oportunidade.Account.RecordType.Name == 'Empresa' ? '0001' : documentoFormat.substring(documentoFormat.length() - 3);
                    contaBancaria.PARTICIPATIONINVESTIMENT = String.valueOf(percentualInvestimento);
                    contaBancaria.ACCOUNTMOVETYPE = infoFinanceiraOportunidade.TipoTransacao__c;

                    objOppGanhaRequest.BANKACCOUNTS.add(contaBancaria);
                }

                objOppGanhaRequestStr = JSON.serialize(objOppGanhaRequest);
            }

            when 'ProdutosFinanceiros', 'ProdutosFinanceirosVeiculos' {
                FormalizacaoSchema.ProtheusOportunidadeGanhaProdFinanceirosRequest objOppGanhaRequest = (FormalizacaoSchema.ProtheusOportunidadeGanhaProdFinanceirosRequest) JSON.deserialize(strObjOppGanha, FormalizacaoSchema.ProtheusOportunidadeGanhaProdFinanceirosRequest.class);
                String documentoBanco = Bdrs.Format.clearNumberFormatting(oportunidade.Banco__r.Documento__c);

                objOppGanhaRequest.PROPOSALTYPE = 'P';
                objOppGanhaRequest.PERCENT = '100';
                objOppGanhaRequest.BUDGET = String.valueOf(oportunidade.ValorFinanciamento__c);
                objOppGanhaRequest.BANKCODECLIENT = documentoBanco.substring(0, 8);
                objOppGanhaRequest.BANKCODESTORE = '0001';
                objOppGanhaRequest.PROPOSALBANK = cotacao.NProposta__c;
                objOppGanhaRequest.PARTNER = parceiroProtheus != null ? parceiroProtheus.Codigo__c : '';

                objOppGanhaRequestStr = JSON.serialize(objOppGanhaRequest);
            }
        }

        objOppGanhaRequestStr = objOppGanhaRequestStr.replace('DATEX', 'DATE').replace('TIMEX', 'TIME').replace('NUMBERX', 'NUMBER');
        return objOppGanhaRequestStr;
    }

    public List<FormalizacaoSchema.PicklistField> construirObjPicklistSimulacao(List<Schema.PicklistEntry> lstPeriodicidadePicklistEntry, List<Schema.PicklistEntry> lstTipoIOFPicklistEntry){
        List<FormalizacaoSchema.PicklistField> listPicklistFields = new List<FormalizacaoSchema.PicklistField>();
        Map<String, String> mapPeriodicidadeLabelValue = new Map<String, String>();
        Map<String, String> mapTipoIOFLabelValue = new Map<String, String>();

        for(Schema.PicklistEntry periodicidade : lstPeriodicidadePicklistEntry)
            mapPeriodicidadeLabelValue.put(periodicidade.getLabel(), periodicidade.getValue());
        
        for(Schema.PicklistEntry tipoIOF : lstTipoIOFPicklistEntry)
            mapTipoIOFLabelValue.put(tipoIOF.getLabel(), tipoIOF.getValue());
        
        FormalizacaoSchema.PicklistField periodicidade = new FormalizacaoSchema.PicklistField();
        periodicidade.fieldName = 'Periodicidade';
        periodicidade.mapLabelValue = mapPeriodicidadeLabelValue;
        listPicklistFields.add(periodicidade);

        FormalizacaoSchema.PicklistField tipoIOF = new FormalizacaoSchema.PicklistField();
        tipoIOF.fieldName = 'Tipo de IOF';
        tipoIOF.mapLabelValue = mapTipoIOFLabelValue;
        listPicklistFields.add(tipoIOF);

        return listPicklistFields;
    }

    public void construirObjHtmlBody(EmailTemplate template, FormalizacaoSchema.SimularParcelasLwcRequest objRequest, FormalizacaoSchema.SimularParcelasResponse objResponse, String userName){
        String htmlBody = template.HtmlValue;
        String outrosCustos = !objRequest.outrosCustos.format().contains(',') ? objRequest.outrosCustos.format() + ',00' : objRequest.outrosCustos.format();
        String taxaCadastro = !objRequest.taxaCadastro.format().contains(',') ? objRequest.taxaCadastro.format() + ',00' : objRequest.taxaCadastro.format();
        String saldoTotal = !objResponse.total_amount_owed.format().contains(',') ? objResponse.total_amount_owed.format() + ',00' : objResponse.total_amount_owed.format();
        String valorSolicitado = !objRequest.valorSolicitado.format().contains(',') ? objRequest.valorSolicitado.format() + ',00' : objRequest.valorSolicitado.format();
        String valorParcela = !objResponse.payment_amount.format().contains(',') ? objResponse.payment_amount.format() + ',00' : objResponse.payment_amount.format();
        String valorLiberado = !objResponse.disbursement_amount.format().contains(',') ? objResponse.disbursement_amount.format() + ',00' : objResponse.disbursement_amount.format();
        String valorFinanciado = !objResponse.financed_amount.format().contains(',') ? objResponse.financed_amount.format() + ',00' : objResponse.financed_amount.format();

        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.ValorSolicitado__c}}}', valorSolicitado);
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.Prazo__c}}}', objRequest.prazo.format());
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.ValorParcela__c}}}', valorParcela);
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.ValorLiberado__c}}}', valorLiberado);
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.ValorFinanciado__c}}}', valorFinanciado);
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.TaxaJuros__c}}}', objRequest.taxaJuros.format());
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.CET__c}}}', (objResponse.monthly_effective_interest_rate * 100).format());
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.TaxaCadastro__c}}}', taxaCadastro);
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.IOF__c}}}', objResponse.iof_amount.format());
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.OutrosCustos__c}}}', outrosCustos);
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.DataPrimeiroPagamento__c}}}', objRequest.dataPrimeiroPagamento.format());
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.DataUltimoPagamento__c}}}', objResponse.last_payment_date.format());
        htmlBody = htmlBody.replace('{{{SimulacaoCredito__c.SaldoTotal__c}}}', saldoTotal);
        htmlBody = htmlBody.replace('{{{Sender.Name}}}', userName);

        template.HtmlValue = htmlBody;
    }

    public void construirObjHtmlBody(EmailTemplate template, String numeroContrato, String urlDownloadContrato, String userName){
        String htmlBody = template.HtmlValue;

        htmlBody = htmlBody.replace('{{{Contrato__c.ContractNumber}}}', numeroContrato);
        htmlBody = htmlBody.replace('{{{UrlContrato}}}', urlDownloadContrato);
        htmlBody = htmlBody.replace('{{{Sender.Name}}}', userName);

        template.HtmlValue = htmlBody;
    }

    public SimulacaoCredito__c construirObjSimulacaoCredito(Id accountId, Id leadId, FormalizacaoSchema.SimularParcelasLwcRequest objRequest, FormalizacaoSchema.SimularParcelasResponse objResponse){
        SimulacaoCredito__c simulacaoCredito = new SimulacaoCredito__c(
            CET__c = objResponse.monthly_effective_interest_rate * 100,
            Conta__c = accountId,
            DataLiberacao__c = objRequest.dataLiberacao,
            DataPrimeiroPagamento__c = objRequest.dataPrimeiroPagamento,
            DataUltimoPagamento__c = objResponse.last_payment_date,
            IOF__c = objResponse.iof_amount,
            Lead__c = leadId,
            OutrosCustos__c = objRequest.outrosCustos,
            Periodicidade__c = objRequest.periodicidade,
            Prazo__c = objRequest.prazo,
            SaldoTotal__c = objResponse.total_amount_owed,
            TaxaCadastro__c = objRequest.taxaCadastro,
            TaxaJuros__c = objRequest.taxaJuros,
            TipoIOF__c = objRequest.tipoIOF,
            ValorFinanciado__c = objResponse.financed_amount,
            ValorLiberado__c = objResponse.disbursement_amount,
            ValorParcela__c = objResponse.payment_amount,
            ValorSolicitado__c = objRequest.valorSolicitado,
            Carencia__c = objRequest.carencia
        );

        return simulacaoCredito;
    }

    public List<SimulacaoParcela__c> construirObjSimulacaoParcela(Id simulacaoCreditoId, FormalizacaoSchema.SimularParcelasResponse objResponse){
        List<SimulacaoParcela__c> lstSimulacaoParcela = new List<SimulacaoParcela__c>();

        for(FormalizacaoSchema.Schedule parcela : objResponse.schedule){
            SimulacaoParcela__c simulacaoParcela = new SimulacaoParcela__c(
                Amortizacao__c = parcela.principal,
                DataVencimento__c = parcela.payment_date,
                IOF__c = parcela.iof,
                Juros__c = parcela.interest,
                Numero__c = parcela.period,
                SimulacaoCredito__c = simulacaoCreditoId,
                ValorVencimento__c = parcela.payment
            );

            lstSimulacaoParcela.add(simulacaoParcela);
        }

        return lstSimulacaoParcela;
    }

    public FormalizacaoSchema.SimularParcelasRequest construirObjSimularParcelasRequest(FormalizacaoSchema.SimularParcelasLwcRequest simulacaoCredito) {
        FormalizacaoSchema.SimularParcelasRequest simularParcelas = new FormalizacaoSchema.SimularParcelasRequest();
        simularParcelas.requestedAmount = simulacaoCredito.valorSolicitado;
        simularParcelas.interestRate = simulacaoCredito.taxaJuros * 0.01;
        simularParcelas.tacAmount = simulacaoCredito.taxaCadastro;
        simularParcelas.financeFee = simulacaoCredito.outrosCustos;
        simularParcelas.iofType = simulacaoCredito.tipoIOF;
        simularParcelas.numPayments = simulacaoCredito.prazo;
        simularParcelas.firstPaymentDate = simulacaoCredito.dataPrimeiroPagamento;
        simularParcelas.disbursementDate = simulacaoCredito.dataLiberacao;
        simularParcelas.scheduleType = simulacaoCredito.periodicidade;
        simularParcelas.carencia = simulacaoCredito.carencia;

        return simularParcelas;
    }

}