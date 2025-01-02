public with sharing class RepresentanteFactory {

    public Map<String, User> gerarObjetoUser(List<RepresentanteSchema.Representante> representantesRequest, String idPerfil, Map<String, Id> mapGerentes, map<String, Boolean> mapDocumentosUserAtivos){
        Map<String, User> mapDocumentoRepresentante = new Map<String, User>();

        for(RepresentanteSchema.Representante representante : representantesRequest){
            Boolean runningInASandbox = Boolean.valueOf([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);

            List<String> userNameSplit = representante.email.split('@');
            String nomeAlias = representante.nome.substring(0,5);
            String numeroDocumento = Bdrs.Format.clearNumberFormatting(representante.documento);
            String primeiroNome = representante.nome.contains(' ') ? representante.nome.substringBefore(' ') : null;
            String sobrenome = primeiroNome != null ? representante.nome.substringAfter(' ') : representante.nome;
            String sufixoAmbiente = runningInASandbox ? '@euro.hml' : '@euro.prd';
            String usuarioFormatado = userNameSplit[0] + sufixoAmbiente;

            User usuario = new User(
                Alias = nomeAlias,
                Documento__c = numeroDocumento,
                Email = representante.email,
                EmailEncodingKey = 'UTF-8',
                FirstName = primeiroNome,
                IdExterno__c = numeroDocumento,
                IsActive = mapDocumentosUserAtivos.get(numeroDocumento),
                LanguageLocaleKey = 'pt_BR',
                LastName = sobrenome,
                LocaleSidKey = 'pt_BR',
                ProfileId = idPerfil,
                TimeZoneSidKey = 'America/Sao_Paulo',
                UserName = usuarioFormatado
            );

            //Tratamento para informações atualmente preenchidas manualmente
            if(!String.isEmpty(representante.funcao))
                usuario.Funcao__c = representante.Funcao;

            if(!String.isEmpty(representante.gerenteResponsavel))
                usuario.ManagerId = mapGerentes.get(representante.gerenteResponsavel);

            if(!String.isEmpty(representante.unidadeNegocio))
                usuario.UnidadeNegocio__c = representante.unidadeNegocio;

            mapDocumentoRepresentante.put(usuario.IdExterno__c, usuario);
        }

        return mapDocumentoRepresentante;
    }

    public Map<String, CodigoProtheus__c> gerarCodigosProtheus(List<RepresentanteSchema.Representante> representantesRequest, Map<String, Id> mapFilial, Map<String, User> mapDocumentoRepresentante){
        Map<String, CodigoProtheus__c> mapChaveCodProtheus = new Map<String, CodigoProtheus__c>();

        for(RepresentanteSchema.Representante representante : representantesRequest){
            if(!String.isBlank(representante.codigoProtheus)){
                String numeroDocumento = Bdrs.Format.clearNumberFormatting(representante.documento);

                CodigoProtheus__c codigoProtheus = new CodigoProtheus__c(
                    Ativo__c = representante.status,
                    Codigo__c = representante.codigoProtheus,
                    Filial__c = mapFilial.get(String.ValueOf(representante.filial)),
                    IdExterno__c =  representante.filial + '|' + numeroDocumento,
                    RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Representante').getRecordTypeId(),
                    Representante__c = mapDocumentoRepresentante.get(numeroDocumento).Id
                );
    
                mapChaveCodProtheus.put(codigoProtheus.IdExterno__c, codigoProtheus);
            }
        }

        return mapChaveCodProtheus;
    }

    public List<Case> criarCasosParaNovosRepresentantes(List<Id> representantesIds, Id recordTypeId, Id FilaId) {
        List<Case> casosParaInserir = new List<Case>();
        for (Id representanteId : representantesIds) {
            Case novoCaso = new Case(
                Representante__c = representanteId,
                Subject = 'Configuração de usuário',
                Description = 'Configuração de usuário',
                Status = 'Novo',
                Type = 'Cadastro',
                RecordTypeId = recordTypeId,
                OwnerId = FilaId
            );
            casosParaInserir.add(novoCaso);
        }
        return casosParaInserir;
    }

}