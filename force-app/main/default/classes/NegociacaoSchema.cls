global class NegociacaoSchema {

    global class FilialRequest{
        global List<Filial> filialFields;
    }

    global class Filial{
        public String filial;
        public String cnpj;
        public String razaoSocial;
        public String codigoEmpresa;
        public String codigoFilial;
        public Boolean status;
    }

    global class ProdutoRequest{
        global List<Produto> produtos;
    }

    global class Produto{
        public String codigoProduto;
        public String nomeProduto;
        public String descricaoProduto;
        public Boolean statusProduto;
        public String filialProduto;
        global List<Filial> filiais;
    }
}