@isTest
private class ApprovalControllTest {
    @isTest
    static void bloquerTest() {
        Account conta = new Account(Name = 'Conta', Documento__c = '41883507000118');
        insert conta;

        List<ApprovalControll.RequestBloqueioRegistro> requests = new List<ApprovalControll.RequestBloqueioRegistro>();
        List<ApprovalControll.RetornoBloqueioRegistro> retorno = new List<ApprovalControll.RetornoBloqueioRegistro>();
        ApprovalControll.RequestBloqueioRegistro request = new ApprovalControll.RequestBloqueioRegistro();

        ApprovalControll.RequestBloqueioRegistro registroBlock = new ApprovalControll.RequestBloqueioRegistro();
        registroBlock.registroId = conta.Id;
        registroBlock.bloquear = true;
        requests.add(registroBlock);

        ApprovalControll.bloquearRegistro(requests);
        System.assertEquals(true, Approval.isLocked(conta.Id));

        registroBlock.registroId = conta.Id;
        registroBlock.bloquear = false;
        requests.add(registroBlock);
        ApprovalControll.bloquearRegistro(requests);
        System.assertEquals(false, Approval.isLocked(conta.Id));

        registroBlock.registroId = null;
        retorno = ApprovalControll.bloquearRegistro(requests);
        System.assert(retorno.get(0).mensagem.contains('Erro'));
    }
}