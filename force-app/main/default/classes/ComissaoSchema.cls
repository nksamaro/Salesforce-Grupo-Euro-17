public class ComissaoSchema {

    public class ComissaoContext {
        public Comissao__c comissao;
        public Account conta;
        public Decimal valorOportunidade;
        public String unidadeNegocio;
        public String tipoNegociacao;
        public TipoComissao tipoComissao;
        public List<TimeRelacionamento__c> timeRelacionamento;
        // public Boolean contemTimeRelaciomento = false;
        // public Boolean contemCelulaRetencao = false;
        // public List<Comissionado> pessoasComissao;
        // public List<Comissionado> pessoasTimeRelacionamento;
        // public List<Comissionado> pessoasCelulaRetencao;
    }

    public enum TipoComissao {
        GerenteAtivo,
        ClienteInativo,
        ExGerenteInativo, 
        ExGerenteParceiro, 
        ExGerenteExcecao
    }

    public class Comissionado {
        public Id usuarioId;
        public String funcao;
        public Decimal percentual;
    }
}


/*

GERENTE DE NEGOCIOS AO PRESIDENTE = Padrao

GNI Principal = Relacionamento da Conta
Indicado = Pode ser qualquer pessoa
GN Opp = dono da oportunidade    

GerenteAtivo = 
    - Se Gerente Ativo 
        Se TimeRelacionamnto.ProprietarioOpp__c == true e tiver valor de Divisão de comissionamento, 
        considerar valores de rateio para ProprietarioOpp__c, Pricipal__c e Indicado (se houver) do TimeRelacionamnto

        Se TimeRelacionamnto.ProprietarioOpp__c == true e NAO tiver valor de Divisão de comissionamento,             
        considerar valores de rateio para ProprietarioOpp__c, Pricipal__c (se houver) do Metadados

        Para a Hierarquia, em ambos os casos, sempre olhar o metadado


ClienteInativo = 
    - Na conta, para cada BU vai ter uma flag de ativação (Ativo Invest, Ativo Securitizadora...)
    - Olhar se o cliente está Inativo
    - Sempre olhar metadado para achar o percentual. Não tem hierarquia
    - Se ClienteInativo ---> Retenção (retençao recebe) = pegar todo mundo que está na fila e dividir o percentual (VAI ESTAR NO METADADO)

Ex gerentes = 
    - Olhar se o cliente está Ativo
    - Olhar a função no Time de relacionamento para descobrir sub-fluxo (ExGerenteInativo, ExGerenteParceiro, ExGerenteExcecao)
    - Fluxos de Excecao Se ClienteInativo ---> Retenção (retençao recebe) = pegar todo mundo que está na fila e dividir o percentual (VAI ESTAR NO METADADO)
    - Sempre olhar metadado para achar o percentual. Não tem hierarquia
    - Diretoria = Vai ser um grupo público, pegar todo mundo que está no grupo e dividir o percentual


Time Relacionamemto.Funcao = 
Gerente de negócio
Gerente geral
Superintendente
Diretor
Vice presidencia
Presidente
Retenção
Ex gerente parceiro
Ex gerente inativo
Ex gerente exceção


-- FIGMA
https://www.figma.com/file/8dzLL83XOT84Q4Pexb7Qmg/Comissionamento-Debenture?type=whiteboard&node-id=45-320&t=R58tBHd7acGzDg0x-0

*/