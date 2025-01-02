public class SendRecordCustomApprovalStepsInvocable {

    private static Map<Id, Id> mapRecordIdHierarquiaAdicional = new Map<Id, Id>();

    @InvocableMethod(label='Enviar registro genérico para aprovação em etapas personalizadas')
    public static void enviarAprovacao(List<Request> lstRequest){
        Integer soqlQueries = 0;
        List<Approval.ProcessSubmitRequest> lstApprovalReq = new List<Approval.ProcessSubmitRequest>();
        List<User> lstHierarquiaUser = new List<User>();
        Map<Id, Set<Id>> mapRecordIdHierarquia = new Map<Id, Set<Id>>();
        Map<Id, String> mapRecordIdProcessoAprovacao = new Map<Id, String>();
        Set<Id> setUserIds = new Set<Id>();

        for(Request req : lstRequest){
            mapRecordIdProcessoAprovacao.put(req.idRegistro, req.processoAprovacao);
            setUserIds.add(req.idProprietario);
        }
            
        lstHierarquiaUser = buscarHierarquiaUsuariosPorSetId(setUserIds);
        soqlQueries++;

        for(Request req : lstRequest)
            construirMapRecordIdHierarquia(req.idProprietario, req.idRegistro, lstHierarquiaUser, mapRecordIdHierarquia);

        //Caso sejam encontradas hierarquias com mais de 6 gerentes, é realizada nova busca. Por se tratar de várias pesquisas SOQL
        //dependendo da hierarquia mapeada, foi estabelecido um limite de 50 consultas para evitar o comprometimento da transação
        while(!mapRecordIdHierarquiaAdicional.values().isEmpty() && soqlQueries < 50){
            lstHierarquiaUser = buscarHierarquiaUsuariosPorSetId(new Set<Id>( mapRecordIdHierarquiaAdicional.values()) );

            for(Id recordId : mapRecordIdHierarquiaAdicional.keySet())
                construirMapRecordIdHierarquia(mapRecordIdHierarquiaAdicional.get(recordId), recordId, lstHierarquiaUser, mapRecordIdHierarquia);

            soqlQueries++;
        }

        for(Id recordId : mapRecordIdHierarquia.keySet()){
            Set<Id> setIdHierarquia = mapRecordIdHierarquia.get(recordId);

            for(Id idHierarquia : setIdHierarquia){
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setObjectId(recordId);
                approvalReq.setProcessDefinitionNameOrId(mapRecordIdProcessoAprovacao.get(recordId));
                approvalReq.setNextApproverIds(new List<Id>{ idHierarquia });
                
                lstApprovalReq.add(approvalReq);
            }
        }

        List<Approval.ProcessResult> processResults = Approval.process(lstApprovalReq);
    }

    public static void construirMapRecordIdHierarquia(Id proprietarioId, Id recordId, List<User> lstHierarquiaUser, Map<Id, Set<Id>> mapRecordIdHierarquia){
        for(User user : lstHierarquiaUser){
            if(user.Id == proprietarioId){
                Integer contHierarquia = 0;
                User usuarioLoop = user.Manager;

                while(usuarioLoop != null){
                    if(String.isBlank(usuarioLoop.Funcao__c) || (!usuarioLoop.Funcao__c.contains('Gerente') && !usuarioLoop.Funcao__c.contains('Vice presidencia'))){
                        if(mapRecordIdHierarquia.get(recordId) == null)
                            mapRecordIdHierarquia.put(recordId, new Set<Id>{ usuarioLoop.Id });
                        else
                            mapRecordIdHierarquia.get(recordId).add(usuarioLoop.Id);
                    } else if(!String.isBlank(usuarioLoop.Funcao__c) && usuarioLoop.Funcao__c.contains('Vice presidencia') && mapRecordIdHierarquia.get(recordId) == null)
                        mapRecordIdHierarquia.put(recordId, new Set<Id>{ usuarioLoop.Id }); 

                    contHierarquia++;

                    //Caso tenham sido encontrados 6 gerentes acima adiciona gerente final para pesquisa adicional
                    if(contHierarquia == 6){
                        mapRecordIdHierarquiaAdicional.put(recordId, usuarioLoop.Id);
                        usuarioLoop = null;
                    } else{
                        if(mapRecordIdHierarquiaAdicional.get(recordId) != null)
                            mapRecordIdHierarquiaAdicional.remove(recordId);

                        usuarioLoop = usuarioLoop.Manager;
                    }
                }
            }
        }
    }

    public static List<User> buscarHierarquiaUsuariosPorSetId(Set<Id> setUserIds){
        return [
            SELECT
                Id,
                Name,
                Manager.Funcao__c,
                Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Manager.Manager.Manager.Funcao__c
            FROM
                User
            WHERE
                Id IN: setUserIds
        ];
    }

    public class Request{
        @InvocableVariable(label='Id do proprietário do registro')
        public Id idProprietario;

        @InvocableVariable(label='Id do registro')
        public Id idRegistro;

        @InvocableVariable(label='Nome do processo de aprovação')
        public String processoAprovacao;
    }

}