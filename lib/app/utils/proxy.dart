// import 'dart:async';
// import 'dart:io';

// import 'package:content_library/content_library.dart';

// /// Inicia um proxy local que encaminha requisições para [targetBaseUrl]
// /// acrescentando [extraHeaders]. Usa porta 0 (aleatória) por padrão.
// Future<HttpServer> startProxy({
//   required String targetBaseUrl,
//   Map<String, String> extraHeaders = const {},
//   required InternetAddress bindAddress,
//   int port = 0, // 0 escolhe porta livre automaticamente
// }) async {
//   final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
//   customLog('Proxy iniciado em http://localhost:8080/');

//   server.listen((HttpRequest clientRequest) async {
//     final httpClient = HttpClient();
//     final uri = Uri.parse(targetBaseUrl);

//     final request = await httpClient.getUrl(uri);
//     extraHeaders.forEach(request.headers.add);

//     final response = await request.close();
//     clientRequest.response.headers.contentType = response.headers.contentType;

//     await response.pipe(clientRequest.response);
//   });

//   return server;
// }

// const _hopByHopHeaders = <String>{
//   'connection',
//   'keep-alive',
//   'proxy-authenticate',
//   'proxy-authorization',
//   'te',
//   'trailers',
//   'transfer-encoding',
//   'upgrade',
// };

// Future<void> _handleClientRequest(
//   HttpRequest clientRequest,
//   String targetBaseUrl,
//   Map<String, String> extraHeaders,
// ) async {
//   HttpClient? httpClient;
//   try {
//     httpClient = HttpClient();

//     // Monta a URI de destino: base + path + query do cliente
//     final base = Uri.parse(targetBaseUrl);
//     // Resolve path relativo do cliente na base (preserva subpaths)
//     final resolved = base.resolveUri(
//       Uri(path: clientRequest.uri.path, query: clientRequest.uri.query),
//     );

//     customLog('Proxy: ${clientRequest.method} ${clientRequest.uri} -> $resolved');

//     // Abre requisição de saída
//     final outboundRequest = await httpClient.openUrl(clientRequest.method, resolved);

//     // Copia headers do cliente para a requisição de saída (exceto hop-by-hop)
//     clientRequest.headers.forEach((name, values) {
//       final lower = name.toLowerCase();
//       if (_hopByHopHeaders.contains(lower)) return;
//       try {
//         outboundRequest.headers.set(name, values.join(','));
//       } catch (e) {
//         // Alguns headers podem falhar ao setar; ignoramos
//       }
//     });

//     // Substitui/insere os headers extras (Referer, User-Agent, Cookie, etc.)
//     extraHeaders.forEach((k, v) {
//       try {
//         outboundRequest.headers.set(k, v);
//       } catch (_) {}
//     });

//     // Se houver body (POST/PUT etc.), encaminha o stream do cliente para a requisição de saída
//     // addStream aceita Stream<List<int>> e retorna Future<void>
//     // HttpRequest (do server) estende Stream<List<int>>
//     // Só encaminhamos se houver conteúdo ou método que normalmente tem body
//     final hasBody =
//         (clientRequest.contentLength > 0) ||
//         <String>{
//           'POST',
//           'PUT',
//           'PATCH',
//           'DELETE',
//         }.contains(clientRequest.method.toUpperCase());
//     if (hasBody) {
//       await outboundRequest.addStream(clientRequest);
//     }
//     // Finaliza a requisição de saída
//     final outboundResponse = await outboundRequest.close();

//     // Propaga status e headers de volta para o cliente (removendo hop-by-hop)
//     clientRequest.response.statusCode = outboundResponse.statusCode;
//     outboundResponse.headers.forEach((name, values) {
//       final lower = name.toLowerCase();
//       if (_hopByHopHeaders.contains(lower)) return;
//       try {
//         clientRequest.response.headers.set(name, values.join(','));
//       } catch (_) {}
//     });

//     // Encaminha o body da resposta
//     await outboundResponse.pipe(clientRequest.response);

//     // Garante fechamento
//     await clientRequest.response.close();
//   } catch (e, st) {
//     // Em caso de erro, tenta enviar 500 pro cliente e fecha
//     customLog(
//       'Erro no proxy ao tratar ${clientRequest.method} ${clientRequest.uri}: $e\n$st',
//     );
//     try {
//       clientRequest.response.statusCode = HttpStatus.internalServerError;
//       clientRequest.response.headers.set('content-type', 'text/plain; charset=utf-8');
//       clientRequest.response.write('Erro interno no proxy: $e');
//       await clientRequest.response.close();
//     } catch (_) {}
//   } finally {
//     // Fecha o HttpClient local usado (pode-se reusar em implementações mais avançadas)
//     httpClient?.close(force: true);
//   }
// }
