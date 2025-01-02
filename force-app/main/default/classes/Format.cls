public class Format {
	public static String documento(String documento) {
		String documentoFormatado;

		if(String.isBlank(documento)) {
			return null;
		}

		if(documento.contains('/') && documento.length() == 18){
			documento = documento.replace('.', '').replace('-', '').replace('/', '');
		}else if(!documento.contains('/') && documento.contains('.') && documento.length() == 14){
			documento = documento.replace('.', '').replace('-', '');
		}

		if(documento.length() == 11) {
			documentoFormatado = documento.substring(0, 3) + '.';
            documentoFormatado += documento.substring(3, 6) + '.';
            documentoFormatado += documento.substring(6, 9) + '-';
            documentoFormatado += documento.substring(9, 11);
			return documentoFormatado;
		} else if(!documento.contains('.') && documento.length() == 14){
			documentoFormatado = documento.substring(0, 2) + '.';
			documentoFormatado += documento.substring(2, 5) + '.';
			documentoFormatado += documento.substring(5, 8) + '/';
			documentoFormatado += documento.substring(8, 12) + '-';
			documentoFormatado += documento.substring(12, 14);
			return documentoFormatado;
		}

		return null;
	}
}