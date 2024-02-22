import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  //1
  final PagamentosIncorreto pagamentos = PagamentosIncorreto();
  pagamentos.pagar();

  //2
  final FuncionarioCorreto zelador = FuncionarioCorreto();
  zelador.trabalhar(Zelador());

  final FuncionarioCorreto porteiro = FuncionarioCorreto();
  porteiro.trabalhar(Porteiro());

  //3
  //A CLASSE IMPLEMENTADA USUARIO PADRAO NAO CONSEGUE SER SUBSTITUIDA COM
  //EFICIENCIA PELA CLASSE BASE IUSUARIO
  IUsuarioIncorreto usuario = UsuarioAdminIncorreto();
  usuario.login();
  usuario.acessarAreaRestrita();
  IUsuarioIncorreto usuario2 = UsuarioPadraoIncorreto();
  usuario2.login();
  usuario2.acessarAreaRestrita();

  //4
  var usuario3 = UsuarioPadrao();
  usuario3.login();
  var usuario4 = UsuarioAdmin();
  usuario4.acessarAreaRestrita();
  usuario4.login();

  //5
  final UsuariosRepositoryCorreto repository =
      UsuariosRepositoryCorreto(HttpClient());
  repository.getUsuarios('url');

  final UsuariosRepositoryCorreto repository2 =
      UsuariosRepositoryCorreto(DioClient());
  repository2.getUsuarios('url');
}

//------------------------------------------------------------------------------

// 1 - RESPONSABILIDADE UNICA (SRP)
// UMA CLASSE DEVE SE REPONSAVEL POR APENAS UMA COISA

// FORMA INCORRETA
class PagamentosIncorreto {
  void pagar() {
    print('pagamento realizado');
    gerarComprovante();
  }

  //ESTE METODO NAO DIZ RESPEITO A PAGAMENTOS
  void gerarComprovante() {
    print('comprovante gerado');
  }
}

// FORMA CORRETA
class PagamentosCorreto {
  void pagar() {
    print('pagamento realizado');
    Comprovantes.gerarComprovante();
  }
}

//É NECESSARIO SEPARAR RESPONSIBILIDADE DE GERAR COMPROVANTES
//PARA SUA PROPRIA CLASSE
class Comprovantes {
  static void gerarComprovante() {
    print('comprovante gerado');
  }
}

//------------------------------------------------------------------------------

// 2 - PRINCIPIO ABERTO-FECHADO
// AS CLASSES TEM QUE SER ABERTA PARA EXTENSAO E FECHADA PARA MODIFICAÇÃO

// FORMA INCORRETA
class FuncionarioIncorreto {
  void trabalhar() {
    print('zelador trabalhando');
  }
}

class ZeladorIncorreto extends FuncionarioIncorreto {}

class PorteiroIncorreto extends FuncionarioIncorreto {}

// FORMA CORRETA
abstract class IFuncionarioCorreto {
  final bool _registraPonto = true;
  void trabalhar() {}
}

//NA HERANÇA VOCE PODE REUTILIZAR OS VALORES HERDADOS
class Porteiro extends IFuncionarioCorreto {
  @override
  void trabalhar() {
    print('porteiro trabalhando');
    print('porteiro ${!_registraPonto ? 'nao' : ''} registra ponto');
  }
}

//NA IMPLEMENTACAO VOCE É OBRIGADO A IMPLEMENTAR TUDO
class Zelador implements IFuncionarioCorreto {
  @override
  void trabalhar() {
    print('zelador trabalhando');
    print('zelador ${!_registraPonto ? 'nao' : ''} registra ponto');
  }

  @override
  final bool _registraPonto = false;
}

//A CLASSE DE PRODUCAO NAO PRECISARA MAIS DE SER ALTERADA
//CASO PRECISE ADICIONAR UM NOVO TIPO DE FUNCIONARIO
class FuncionarioCorreto {
  void trabalhar(IFuncionarioCorreto funcionario) {
    funcionario.trabalhar();
  }
}

//------------------------------------------------------------------------------

// 3- PRINCIPIO DA SUBSTITUICAO DE LISKOV (LSP)
// CLASSES DERIVADAS DEVEM PODER SER SUBSTITUIDAS POR SUAS CLASSES BASES
// FORMA INCORRETA

abstract class IUsuarioIncorreto {
  void login();
  void acessarAreaRestrita();
}

class UsuarioAdminIncorreto implements IUsuarioIncorreto {
  @override
  void acessarAreaRestrita() {
    print('acessando area restrita');
  }

  @override
  void login() {
    print('realizando login');
  }
}

class UsuarioPadraoIncorreto implements IUsuarioIncorreto {
  @override
  void acessarAreaRestrita() {
    throw Exception('este usuario nao possui acesso');
  }

  @override
  void login() {
    print('realizando login');
  }
}

//------------------------------------------------------------------------------

// 4- PRINCIPIO DA SEGREGAÇÃO DA INTERFACE (ISP)
// NENHUMA CLASSE DEVE SER FORCADA A DEPENDER DE METODOS QUE NAO UTILIZA
// FORMA CORRETA

//MODELO DE CONTRATO PARA UM USUARIO PADRAO
abstract class IUsuarioPadrao {
  void login();
}

//MODELO DE CONTRATO PARA UM USUARIO ADMIN
abstract class IUsuarioAdmin {
  void acessarAreaRestrita();
}

class UsuarioPadrao implements IUsuarioPadrao {
  @override
  void login() {
    print('realizando login');
  }
}

class UsuarioAdmin implements IUsuarioAdmin, IUsuarioPadrao {
  @override
  void acessarAreaRestrita() {
    print('acessando area restrita');
  }

  @override
  void login() {
    print('realizando login');
  }
}

//------------------------------------------------------------------------------

// 5- PRINCIPIO DA INVERSAO DE DEPENDENCIAS (DIP)
// SEMPRE DEPENDER DE ABSTRACOES E NAO DE CLASSES CONCRETAS

// FORMA INCORRETA
class UsuariosRepositoryIncorreto {
  //ESTA INICIANDO UMA DEPENDENCIA DE FORMA DIRETA
  //SE PRECISAR ALTERAR O CLIENT ALGUM DIA VAI SER NECESSARIO
  //ALTERAR O REPOSITORIO, QUEBRANDO O PRINCIPIO
  var client = http.Client();

  void getUsuarios(String url) {
    client.get(Uri.parse('https://www.google.com'));
  }
}

// FORMA INCORRETA
abstract class IHttpClient {
  get(String url);
}

class HttpClient implements IHttpClient {
  final client = http.Client();

  @override
  get(String url) {
    client.get(Uri.parse(url));
  }
}

class DioClient implements IHttpClient {
  final Dio dio = Dio();

  @override
  get(String url) {
    dio.get(url);
  }
}

class UsuariosRepositoryCorreto {
  //FORMA CORRETA SRIA RECEBER ESTA DEPENDENCIA
  //PELO CONSTRUTOR E ESTA TAMBEM PRECISA SER UMA ABSTRACAO
  final IHttpClient client;

  UsuariosRepositoryCorreto(this.client);

  void getUsuarios(String url) {
    client.get(url);
  }
}
