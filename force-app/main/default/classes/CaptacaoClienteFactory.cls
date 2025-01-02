public class CaptacaoClienteFactory {

    private CaptacaoClienteRepository repository = new CaptacaoClienteRepository();

    //Realiza parse de CaptacaoClienteSchema.LeadRequest para Lead
    public Lead gerarObjetoLead(CaptacaoClienteSchema.LeadRequest leadRequest) {

        String documentoFormatado = Format.documento(leadRequest.documento);
        Id idProduto;
        Id idTipoRegistro;
        Lead novoLead = new Lead();

        switch on leadRequest.origem {
            when 'Site Euro Securitizadora', 'Site Euro Prime Securitizadora' {
                idTipoRegistro = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('OperacoesEstruturadas').getRecordTypeId();
                if(leadRequest.produtoInteresse == 'Antecipação de recebíveis' || leadRequest.produtoInteresse == 'Giro Parcelado' || leadRequest.produtoInteresse == 'Conta Escrow') {
                    idProduto = [SELECT Id, Name FROM Product2 WHERE Name =:'Capital de giro'].Id;
                }

                String telefone = Bdrs.Format.clearNumberFormatting(leadRequest.telefone);
                novoLead = new Lead(
                    LastName = leadRequest.nome,
                    Documento__c = documentoFormatado,
                    Email = leadRequest.email,
                    MobilePhone = telefone.length() == 11 ? telefone : null,
                    Phone = telefone.length() != 11 ? telefone : null,
                    LeadSource = leadRequest.origem,
                    TipoPessoa__c = documentoFormatado.length() == 18 ? 'Pessoa jurídica' : 'Pessoa física',
                    ProdutoNegociar__c = idProduto,
                    ProdutoInteresse__c = leadRequest.produtoInteresse,
                    RecordTypeId = idTipoRegistro
                );
            }
            when 'Site Euro 17 Crédito' {
                idTipoRegistro = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ProdutosFinanceiros').getRecordTypeId();

                if(leadRequest.produtoInteresse != null) {
                    idProduto = repository.buscarProdutoPorNome(leadRequest.produtoInteresse).Id;
                }

                novoLead =  new Lead(
                    LastName = leadRequest.nome,
                    Email = leadRequest.email,
                    Documento__c = documentoFormatado,
                    LeadSource = leadRequest.origem,
                    TipoPessoa__c = documentoFormatado.length() == 18 ? 'Pessoa jurídica' : 'Pessoa física',
                    Phone = leadRequest.telefone,
                    MobilePhone = leadRequest.celular,
                    ComporRenda__c = leadRequest.comporRenda,
                    ValorBem__c = leadRequest.valorImovel,
                    ValorFinanciamento__c = leadRequest.valorFinanciamento,
                    PrazoOperacao__c = leadRequest.prazo,
                    Placa__c = leadRequest.placa,
                    Restricao__c = leadRequest.restricao,
                    Originador__c = leadRequest.originador,
                    ProdutoNegociar__c = idProduto,
                    RecordTypeId = idTipoRegistro
                );
            }
            when else {
                throw new CaptacaoCliente.CaptacaoClienteException('Erro na criação do lead: Origem não mapeada');
            }
        }

        return novoLead;
    }

    //Realiza parse de CaptacaoClienteSchema.LeadRequest para Oportunidade
    public Opportunity gerarObjetoOportunidade(CaptacaoClienteSchema.LeadRequest leadRequest, String fase) {
        return new Opportunity(
            Name = leadRequest.nome,
            AccountId = leadRequest.contaExistenteId,
            CloseDate = System.today(),
            StageName =  fase,
            LeadSource = leadRequest.origem
        );
    }

    //Realiza parse de CaptacaoClienteSchema.LeadRequest para RendaComplementar
    public RendaComplementar__c gerarObjetoRendaComplementar(CaptacaoClienteSchema.LeadRequest leadRequest, Id idLead) {
        String documentoFormatado = Format.documento(leadRequest.documento);

        return new RendaComplementar__c(
            NomeCompleto__c = leadRequest.nome,
            TipoRenda__c = 'Principal',
            Email__c = leadRequest.email,
            Documento__c = documentoFormatado,
            TipoPessoa__c = documentoFormatado.length() == 18 ? 'Pessoa jurídica' : 'Pessoa física',
            Telefone__c = leadRequest.telefone,
            Celular__c = leadRequest.celular,
            EstadoCivil__c = leadRequest.estadoCivil,
            Renda__c = leadRequest.renda,
            Lead__c = idLead
        );
    }
}