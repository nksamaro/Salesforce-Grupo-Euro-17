public class CaptacaoClienteService {
    private CaptacaoClienteRepository repository = new CaptacaoClienteRepository();
    private CaptacaoCliente captacaoCliente = new CaptacaoCliente();

    //Executa criação de novo lead ou oportunidade
    public void criarLead(CaptacaoClienteSchema.LeadRequest leadRequest) {
        if(leadRequest.origem == 'Site Euro 17 Crédito') {
            verificarLeadComMesmoProdutoFinanceiro(leadRequest.documento, leadRequest.produtoInteresse);
        }

        //Busca possiveis contas já cadastradas com o CNPJ do lead a ser criado
        List<Account> contas = this.repository.buscarContasPorDocumento(new Set<String>{Format.documento(leadRequest.documento)});        
        this.captacaoCliente.criarLeadOportunidade(leadRequest, contas);
    }

    //Verifica se uma conta já existe
    public void validarContasExistente(List<Account> contas) {
        Set<String> documentos = new Set<String>();
        Set<String> documentosContasExistentes = new Set<String>();

        for(Account acc : contas){
            //TODO: FAZER TRATAMENTO PARA TRATAR CPF TBM
            documentos.add(Format.documento(acc.Documento__c));
        }

        for(Account contaExistente : this.repository.buscarContasPorDocumento(documentos)) {
            documentosContasExistentes.add(contaExistente.Documento__c);
        }
        
        this.captacaoCliente.validarContasExistentes(contas, documentosContasExistentes);
    }

    public void validarDadosBancariosExistentes(List<DadoBancario__c> listDadosBancarios){
        Map<String, DadoBancario__c> mapChaveCompostaDadoBancarioTransacao = new Map<String, DadoBancario__c>();
        Set<Id> setIdLead = new Set<Id>();
        Set<String> setCodAgencia = new Set<String>();
        Set<String> setCodBanco = new Set<String>();
        Set<String> setContaBancaria = new Set<String>();
        Set<String> setDigitoBancario = new Set<String>();
    
        for(DadoBancario__c dadoBancario : listDadosBancarios){
            String chaveComposta = dadoBancario.Lead__c + ' | ' + dadoBancario.InstituicaoFinanceira__c + ' | ' + dadoBancario.Agencia__c + ' | ' + dadoBancario.Conta__c + ' | ' + dadoBancario.DV__c;
            DadoBancario__c dadoBancarioTransacao = mapChaveCompostaDadoBancarioTransacao.get(chaveComposta);

            if(dadoBancarioTransacao != null)
                dadoBancario.addError('Já existe um registro de Dado bancário para este lead com as mesmas informações de instituição financeira, agência, conta e DV fornecidas nesta mesma transação.');
            else{
                mapChaveCompostaDadoBancarioTransacao.put(chaveComposta, dadoBancario);
                setIdLead.add(dadoBancario.Lead__c);
                setCodAgencia.add(dadoBancario.Agencia__c);
                setCodBanco.add(dadoBancario.InstituicaoFinanceira__c);
                setContaBancaria.add(dadoBancario.Conta__c);
                setDigitoBancario.add(dadoBancario.DV__c);
            }
        }

        if(!setIdLead.isEmpty()){         
            List<DadoBancario__c> listDadosBancariosExistentes = this.repository.buscarDadosBancariosExistentes(setIdLead, setCodAgencia, setCodBanco, setContaBancaria, setDigitoBancario);
            Map<String, DadoBancario__c> mapChaveCompostaDadoBancario = new Map<String, DadoBancario__c>();

            for(DadoBancario__c dadoBancarioExistente : listDadosBancariosExistentes)
                mapChaveCompostaDadoBancario.put(dadoBancarioExistente.Lead__c + ' | ' + dadoBancarioExistente.InstituicaoFinanceira__c + ' | ' + 
                    dadoBancarioExistente.Agencia__c + ' | ' + dadoBancarioExistente.Conta__c + ' | ' + dadoBancarioExistente.DV__c, dadoBancarioExistente);
    
            for(DadoBancario__c dadoBancario : listDadosBancarios){
                String chaveComposta = dadoBancario.Lead__c + ' | ' + dadoBancario.InstituicaoFinanceira__c + ' | ' + dadoBancario.Agencia__c + ' | ' + dadoBancario.Conta__c + ' | ' + dadoBancario.DV__c;
                DadoBancario__c dadoBancarioExistente = mapChaveCompostaDadoBancario.get(chaveComposta);

                if(dadoBancarioExistente != null && dadoBancarioExistente.Id != dadoBancario.Id)
                    dadoBancario.addError('Já existe um registro de Dado bancário para este lead com as mesmas informações de instituição financeira, agência, conta e DV fornecidas.');
            }
        }
    }

    public void validarInfoFinanceirasContaExistentes(List<InformcoesFinanceirasConta__c> listInfoFinanceirasConta){
        Id dadoBancarioRecTypeId = Schema.SObjectType.InformcoesFinanceirasConta__c.getRecordTypeInfosByDeveloperName().get('DadoBancario').getRecordTypeId();
        List<InformcoesFinanceirasConta__c> listInfoFinaceirasContaDB = new List<InformcoesFinanceirasConta__c>();
        Map<String, InformcoesFinanceirasConta__c> mapChaveCompostaInfoFinanceiraTransacao = new Map<String, InformcoesFinanceirasConta__c>();
        Set<Id> setIdConta = new Set<Id>();
        Set<String> setCodAgencia = new Set<String>();
        Set<String> setCodBanco = new Set<String>();
        Set<String> setContaBancaria = new Set<String>();
        Set<String> setDigitoBancario = new Set<String>();
    
        for(InformcoesFinanceirasConta__c infoFinanceira : listInfoFinanceirasConta){
            if(infoFinanceira.RecordTypeId == dadoBancarioRecTypeId){
                String chaveComposta = infoFinanceira.ContaRelacionada__c + ' | ' + infoFinanceira.InstituicaoFinaneira__c + ' | ' + infoFinanceira.Agencia__c + ' | ' + infoFinanceira.Conta__c + ' | ' + infoFinanceira.DV__c;
                InformcoesFinanceirasConta__c infoFinanceiraTransacao = mapChaveCompostaInfoFinanceiraTransacao.get(chaveComposta);

                if(infoFinanceiraTransacao != null)
                    infoFinanceira.addError('Já existe um registro de Dado bancário para este cliente com as mesmas informações de instituição financeira, agência, conta e DV fornecidas nesta mesma transação.');
                else{
                    listInfoFinaceirasContaDB.add(infoFinanceira);
                    mapChaveCompostaInfoFinanceiraTransacao.put(chaveComposta, infoFinanceira);
                    setIdConta.add(infoFinanceira.ContaRelacionada__c);
                    setCodAgencia.add(infoFinanceira.Agencia__c);
                    setCodBanco.add(infoFinanceira.InstituicaoFinaneira__c);
                    setContaBancaria.add(infoFinanceira.Conta__c);
                    setDigitoBancario.add(infoFinanceira.DV__c);
                }
            }
        }

        if(!setIdConta.isEmpty()){         
            List<InformcoesFinanceirasConta__c> listInfoFinanceirasContaExistentes = this.repository.buscarInformacoesFinanceirasContaExistentes(setIdConta, setCodAgencia, setCodBanco, setContaBancaria, setDigitoBancario);
            Map<String, InformcoesFinanceirasConta__c> mapChaveCompostaInfoFinanceira = new Map<String, InformcoesFinanceirasConta__c>();

            for(InformcoesFinanceirasConta__c infoFinanceiraExistente : listInfoFinanceirasContaExistentes)
                mapChaveCompostaInfoFinanceira.put(infoFinanceiraExistente.ContaRelacionada__c + ' | ' + infoFinanceiraExistente.InstituicaoFinaneira__c + ' | ' + 
                    infoFinanceiraExistente.Agencia__c + ' | ' + infoFinanceiraExistente.Conta__c + ' | ' + infoFinanceiraExistente.DV__c, infoFinanceiraExistente);
    
            for(InformcoesFinanceirasConta__c infoFinanceiraDB : listInfoFinaceirasContaDB){
                String chaveComposta = infoFinanceiraDB.ContaRelacionada__c + ' | ' + infoFinanceiraDB.InstituicaoFinaneira__c + ' | ' + infoFinanceiraDB.Agencia__c + ' | ' + infoFinanceiraDB.Conta__c + ' | ' + infoFinanceiraDB.DV__c;
                InformcoesFinanceirasConta__c infoFinanceiraExistente = mapChaveCompostaInfoFinanceira.get(chaveComposta);

                if(infoFinanceiraExistente != null && infoFinanceiraExistente.Id != infoFinanceiraDB.Id)
                    infoFinanceiraDB.addError('Já existe um registro de Dado bancário para este cliente com as mesmas informações de instituição financeira, agência, conta e DV fornecidas.');
            }
        }
    }

    public void formatarDocumentoConta(List<Account> contas){
        for(Account conta : contas){
            if(conta.Documento__c != null && (conta.Documento__c.length() == 18 || conta.Documento__c.length() == 14 || conta.Documento__c.length() == 11)){
                conta.Documento__c = Format.documento(conta.Documento__c);
            } else {
                conta.addError('Para o campo documento, digitar somente um CPF ou CNPJ válido. Não é possível salvar o campo somente com letras ou com uma sequência de mesmo número. Ex: 111111111-11.');
            }
        }
    }

    public void formatarDocumentoLead(List<Lead> leads){
        Set<String> origemLead = new Set<String>{'Site Euro Securitizadora'};
        for(Lead lead : leads){
            if(lead.Documento__c != null ){
                if(!origemLead.contains(lead.LeadSource) && (lead.Documento__c.length() == 18 || lead.Documento__c.length() == 14 || lead.Documento__c.length() == 11)){
                    lead.Documento__c = Format.documento(lead.Documento__c);
                }else if(origemLead.contains(lead.LeadSource)){
                    lead.Documento__c = Format.documento(lead.Documento__c);
                } else {
                    lead.addError('Para o campo documento, digitar somente um CPF ou CNPJ válido. Não é possível salvar o campo somente com letras ou com uma sequência de mesmo número. Ex: 111111111-11.');
                }
            }
        }
    }

    public CaptacaoClienteSchema.LeadConversionResponse converterLead(CaptacaoClienteSchema.LeadConversionRequest leadRequest) {
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        List<Account> contaExistente = this.repository.buscarContasPorDocumento(new Set<String>{leadRequest.documentoLead});
                    
        return captacaoCliente.converterLead(leadRequest, contaExistente);
    }

    public void verificarLeadComMesmoProdutoFinanceiro(String documento, String nomeProduto) {
        String documentoFormatado = Format.documento(documento);
        Id idProduto = repository.buscarProdutoPorNome(nomeProduto).Id;
        Id idTipoRegistro = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ProdutosFinanceiros').getRecordTypeId();

        List<Lead> leads = this.repository.buscarLeadPorDocumentoEProdutoDiaAtual(documentoFormatado, idProduto, idTipoRegistro);

        if(leads.size() > 0) {
            throw new CaptacaoClienteServiceException('Existe uma solicitação em andamento para o produto solicitado. Em breve retornaremos o contato.');
        }
    }

    public class CaptacaoClienteServiceException extends Exception {}
}