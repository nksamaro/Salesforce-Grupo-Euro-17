public class CaptacaoClienteRepository {
    public List<Account> buscarContasPorDocumento(Set<String> documentos) {
        return [
            SELECT 
                Id,
                Owner.Name,
                Documento__c
            FROM 
                Account 
            WHERE 
                Documento__c IN: documentos
        ];
    }

    public List<DadoBancario__c> buscarDadosBancariosExistentes(Set<Id> setIdLead, Set<String> setCodAgencia, Set<String> setCodBanco, Set<String> setContaBancaria, Set<String> setDigitoBancario){
        return [
            SELECT
                Id,
                Agencia__c,
                Conta__c,
                DV__c,
                Lead__c,
                InstituicaoFinanceira__c
            FROM
                DadoBancario__c
            WHERE
                Agencia__c != null AND Agencia__c IN :setCodAgencia
            AND
                Conta__c != null AND Conta__c IN :setContaBancaria
            AND
                Lead__c != null AND Lead__c IN :setIdLead
            AND 
                DV__c != null AND DV__c IN :setDigitoBancario
            AND
                InstituicaoFinanceira__c != null AND InstituicaoFinanceira__c IN :setCodBanco
            WITH
                SYSTEM_MODE
            ORDER BY
                CreatedDate DESC
        ];
    }

    public List<InformcoesFinanceirasConta__c> buscarInformacoesFinanceirasContaExistentes(Set<Id> setIdConta, Set<String> setCodAgencia, Set<String> setCodBanco, Set<String> setContaBancaria, Set<String> setDigitoBancario){
        return [
            SELECT
                Id,
                Agencia__c,
                Conta__c,
                ContaRelacionada__c,
                DV__c,
                InstituicaoFinaneira__c
            FROM
                InformcoesFinanceirasConta__c
            WHERE
                Agencia__c != null AND Agencia__c IN :setCodAgencia
            AND
                Conta__c != null AND Conta__c IN :setContaBancaria
            AND
                ContaRelacionada__c != null AND ContaRelacionada__c IN :setIdConta
            AND 
                DV__c != null AND DV__c IN :setDigitoBancario
            AND
                InstituicaoFinaneira__c != null AND InstituicaoFinaneira__c IN :setCodBanco
            WITH
                SYSTEM_MODE
            ORDER BY
                CreatedDate DESC
        ];
    }

    public List<Lead> buscarLeadPorDocumentoEProdutoDiaAtual(String documentoFormatado, Id idProduto, Id idTipoRegistro) {
        return [
            SELECT 
                Id,
                Documento__c,
                ProdutoNegociar__c
            FROM 
                Lead 
            WHERE 
                Documento__c =: documentoFormatado AND
                ProdutoNegociar__c =: idProduto AND
                CreatedDate = TODAY
        ];
    }

    public Product2 buscarProdutoPorNome(String nomeProduto) {
        Map<String, String> produtosEuro17Credito = new Map<String, String>{
            'Financiamento de imóvel' => 'FINANCIAMENTO DE IMOVEIS',
            'Veículo pesado em garantia' => 'EMPRESTIMO C/ GAR. VEIC.PESADO',
            'Financiamento de veículo' => 'FINANCIAMENTO DE VEICULOS',
            'Veículo em garantia' => 'EMPRESTIMO C/GARANTIA VEICULOS',
            'Imóvel em garantia' => 'EMPRESTIMO C/ GARANTIA IMOVEIS'
        };

        nomeProduto = produtosEuro17Credito.get(nomeProduto);

        return [
            SELECT 
                Id,
                Name
            FROM 
                Product2 
            WHERE 
                Name =:nomeProduto
            LIMIT 1
        ];
    }
}