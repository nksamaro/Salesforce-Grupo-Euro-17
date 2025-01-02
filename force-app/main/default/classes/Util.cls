public class Util {
    
    public static String removerAcentosCaracteres(String caracteres){
        return caracteres?.replaceAll('[ÁÀÂÃÄ]', 'A').replaceAll('[áàâãä]', 'a').replace('Ç', 'C').replace('ç', 'c')
                          .replaceAll('[ÉÈÊË]', 'E').replaceAll('[éèêë]', 'e').replaceAll('[ÍÌÎÏ]', 'I').replaceAll('[íìîï]', 'i')
                          .replaceAll('[ÓÒÔÕÖ]', 'O').replaceAll('[óòôõö]', 'o').replaceAll('[ÚÙÛÜ]', 'U').replaceAll('[úùûü]', 'u');
    }

    public static List<SObject> retornarListaFiltradaCampoBoolean(List<SObject> lstObj, String nomeCampo, Boolean valorCampo){
        List<SObject> lstObjFiltro = new List<SObject>();

        for(SObject obj : lstObj)
            if(obj.get(nomeCampo) == valorCampo)
                lstObjFiltro.add(obj);

        return lstObjFiltro;
    }

}