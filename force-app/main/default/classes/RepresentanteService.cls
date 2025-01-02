global class RepresentanteService {

    /* Os comentários presentes nas classes Representante, RepresentanteRepository e RepresentanceService foram adicionados para 
        caso futuramente seja necessário inativar a relação entre representante e filial anteriores, mantendo apenas os recentes ativos.
        Para funcionamento, basta retirar os comentários das classes mencionadas. */

    private Representante representanteClass = new Representante();
    private RepresentanteFactory factory = new RepresentanteFactory();
    private RepresentanteRepository repository = new RepresentanteRepository();

    global void criarRepresentantes(RepresentanteSchema.RepresentantesRequest representanteRequest){
        List<CodigoProtheus__c> lstCodProtheusAnteriores = new List<CodigoProtheus__c>();
        List<Filial__c> filiais = new List<Filial__c>();
        List<Profile> perfis = new List<Profile>();
        List<User> usuarios = new List<User>();
        Map<String, CodigoProtheus__c> mapChaveCodProtheus = new Map<String, CodigoProtheus__c>();
        Map<String, Id> mapFiliais = new Map<String, Id>();
        Map<String, Id> mapGerentes = new Map<String, Id>();
        Map<String, User> mapDocumentoRepresentante = new Map<String, User>();
        Map<String, Boolean> mapDocumentosUserAtivos = new Map<String, Boolean>();
        Set<Id> setRepresentantesIds = new Set<Id>();
        Set<String> codFilial = new Set<String>();
        Set<String> documentos = new Set<String>();
        Set<String> setNomesGerentes = new Set<String>();
    
        List<RepresentanteSchema.Representante> representantes = representanteRequest.representantes;

        Id representanteRecTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Representante').getRecordTypeId();
       
        for(RepresentanteSchema.Representante forRepresentante : representantes){
            String numeroDocumento = Bdrs.Format.clearNumberFormatting(forRepresentante.documento);
            documentos.add(numeroDocumento);
            if(forRepresentante.filial != null)
                codFilial.add(forRepresentante.filial);
            
            if(forRepresentante.gerenteResponsavel != null)
                setNomesGerentes.add(forRepresentante.gerenteResponsavel);
        }
        
        List<CodigoProtheus__c> codigosProtheusAtivos = repository.buscarCodigosProtheusAtivos(documentos, representanteRecTypeId);

        for (RepresentanteSchema.Representante forRepresentante : representantes) {
            String numeroDocumento = Bdrs.Format.clearNumberFormatting(forRepresentante.documento);
            if (!forRepresentante.status) {
                for (CodigoProtheus__c codigosAtivo : codigosProtheusAtivos) {
                    if (codigosAtivo.Representante__r.Documento__c == numeroDocumento && codigosAtivo.Codigo__c != forRepresentante.codigoProtheus ) {
                        mapDocumentosUserAtivos.put(numeroDocumento, true);
                        break;
                    }
                }
                
                if (mapDocumentosUserAtivos.get(numeroDocumento) == null) 
                    mapDocumentosUserAtivos.put(numeroDocumento, false);

            } else 
                mapDocumentosUserAtivos.put(numeroDocumento, forRepresentante.status);
        }

        filiais = this.repository.buscarFilialPorCodigo(codFilial);

        if(codFilial.size() == 0 || codFilial.size() != filiais.size())
            throw new Representante.RepresentanteException('Filial não encontrada');

        usuarios = this.repository.buscarUsuarioPeloNome(setNomesGerentes);
        perfis = this.repository.buscarPerfilPeloNome('Grupo Euro 17');

        for(Filial__c filial : filiais)
            mapFiliais.put(filial.CodigoFilial__c, filial.Id);

        for(User gerente : usuarios)
            mapGerentes.put(gerente.Name, gerente.Id);
    
        mapDocumentoRepresentante = this.factory.gerarObjetoUser(representanteRequest.representantes, perfis[0].Id, mapGerentes, mapDocumentosUserAtivos);
        
        List<Id> novosRepresentantesIds = this.representanteClass.criarRepresentante(mapDocumentoRepresentante);

        mapChaveCodProtheus = this.factory.gerarCodigosProtheus(representanteRequest.representantes, mapFiliais, mapDocumentoRepresentante);
        Representante.criarCodigoProtheus(JSON.serialize(mapChaveCodProtheus));

        /* for(CodigoProtheus__c codigoProtheus : mapChaveCodProtheus.values())
            setRepresentantesIds.add(codigoProtheus.Representante__c);

        Id representanteRecTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Representante').getRecordTypeId();
        lstCodProtheusAnteriores = this.repository.buscarCodigosProtheusExistentes(representanteRecTypeId, setRepresentantesIds, mapChaveCodProtheus.keySet());

        for(CodigoProtheus__c codigoProtheus : lstCodProtheusAnteriores)
            codigoProtheus.Ativo__c = false;

        Representante.inativarCodigosAnteriores(JSON.serialize(lstCodProtheusAnteriores)); */


        if (!novosRepresentantesIds.isEmpty()) {
            Id caseRecordTypeId = repository.buscarRecordType('Suporte');
            Id filaId = repository.buscarFila('Cadastramento');
            List<Case> casosParaInserir = factory.criarCasosParaNovosRepresentantes(novosRepresentantesIds, caseRecordTypeId, FilaId);
            String casosJson = JSON.serialize(casosParaInserir);
            Representante.inserirCasos(casosJson); 
        }
    }

}