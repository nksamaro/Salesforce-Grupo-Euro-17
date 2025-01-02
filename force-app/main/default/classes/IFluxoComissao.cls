//Define chamadas necessárias para execucão dos fluxos de comissão
public interface IFluxoComissao {
    ComissaoSchema.TipoComissao definirTipoComissao(ComissaoSchema.ComissaoContext context);

    List<Comissionado__c> encontrarComissionados(ComissaoSchema.ComissaoContext context);
}