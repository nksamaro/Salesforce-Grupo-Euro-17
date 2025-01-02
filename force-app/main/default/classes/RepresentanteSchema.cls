global class RepresentanteSchema {
    
    global class RepresentantesRequest{
        global list<Representante> representantes;
    }

    global class Representante{
        public String nome;
        public String documento;
        public String email;
        public String codigoProtheus;
        public Boolean status;
        public String gerenteResponsavel;
        public String funcao;
        public String filial;
        public String unidadeNegocio;
    }
}