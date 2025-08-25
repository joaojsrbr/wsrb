extension FutureExtentions<T> on Future<T> {
  Future<T> retry(int retries) async {
    late Object ultimoErro;

    for (int i = 0; i < retries; i++) {
      try {
        // Tenta executar a operação e retorna o resultado se for bem-sucedido.
        return await then((value) => value);
      } catch (e) {
        // Guarda o erro e continua para a próxima tentativa.
        ultimoErro = e;
        // print('Tentativa ${i + 1} falhou. Tentando novamente...');
        await Future.delayed(const Duration(seconds: 1)); // Pausa opcional
      }
    }

    // Se o loop terminar, todas as tentativas falharam. Lança o último erro capturado.
    throw ultimoErro;
  }
}
