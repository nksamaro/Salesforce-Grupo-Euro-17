public class CaptacaoCliente {
    private CaptacaoClienteFactory factory = new CaptacaoClienteFactory();
    private CaptacaoClienteRepository repository = new CaptacaoClienteRepository();
    //Realiza criação de lead ou oportunidade de acordo com as regras
    public void criarLeadOportunidade(CaptacaoClienteSchema.LeadRequest leadRequest, List<Account> contas) {
        try {
        
            if(contas.isEmpty()) {
                Savepoint savePoint = Database.setSavepoint();

                Lead novoLead =  this.factory.gerarObjetoLead(leadRequest);
                insert novoLead;

                if(leadRequest.origem == 'Site Euro 17 Crédito') {
                    RendaComplementar__c rendaComplementar = this.factory.gerarObjetoRendaComplementar(leadRequest, novoLead.Id);
                    Database.SaveResult rendaSaveResult = Database.insert(rendaComplementar, false);

                    // Se houver um erro ao inserir o RendaComplementar__c, realiza rollback no Lead
                    if (!rendaSaveResult.isSuccess()) {
                        Database.rollback(savePoint);
                        throw new CaptacaoClienteException('Renda complementar: ' + rendaSaveResult.getErrors()[0].getMessage());
                    }
                }

            } else {
                leadRequest.contaExistenteId = contas.get(0).Id;
                Opportunity novaOportunidade =  this.factory.gerarObjetoOportunidade(leadRequest, 'Qualification');

                insert novaOportunidade;
            }            
        } catch (Exception ex) {
            throw new CaptacaoClienteException('Erro na criação do lead: ' + ex.getMessage());
        } 
    }

    //Verifica se na lista de contas, já não existe alguma conta já existente no Set
    public void validarContasExistentes(List<Account> contas, Set<String> documentosContasExistentes) {
        if(!documentosContasExistentes.isEmpty()){
            Map<String, Account> ownerNameByDocumento = new Map<String, Account>();
            for (Account dono : this.repository.buscarContasPorDocumento(documentosContasExistentes)) {
                ownerNameByDocumento.put(Format.documento(dono.Documento__c), dono);
            }

            for(Account conta : contas) {
                String documentoConta = Format.documento(conta.Documento__c);
                if (ownerNameByDocumento.containsKey(documentoConta)) {
                    Account dono = ownerNameByDocumento.get(documentoConta);
                    conta.addError('Cliente já existente na base. Proprietário responsável: ' + dono.Owner.Name + '. Por gentileza, realizar a busca da conta existente pelo documento ou nome');
                }
            }
        }
    }

    //Realiza a conversão do lead
    public CaptacaoClienteSchema.LeadConversionResponse converterLead(CaptacaoClienteSchema.LeadConversionRequest leadRequest, List<Account> contaExistente) { 
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        CaptacaoClienteSchema.LeadConversionResponse resposta = new CaptacaoClienteSchema.LeadConversionResponse();

        if(contaExistente.isEmpty()) {
            leadConvert.setLeadId(leadRequest.leadId);
            leadConvert.setConvertedStatus(leadRequest.convertedStatus);
            leadConvert.setOpportunityName(leadRequest.nomeOportunidade);
        } else {
            //Se conta já existir, não cria novamente
            leadConvert.setLeadId(leadRequest.leadId);
            leadConvert.setAccountId(contaExistente[0].Id);
            leadConvert.setConvertedStatus(leadRequest.convertedStatus);
            leadConvert.setOpportunityName(leadRequest.nomeOportunidade);
        }
        
        Database.LeadConvertResult resultado = Database.convertLead(leadConvert);

        resposta.contaId = resultado.getAccountId();
        resposta.oportunidadeId = resultado.getOpportunityId();
        
        return resposta;
    }

    public class CaptacaoClienteException extends Exception {}
}