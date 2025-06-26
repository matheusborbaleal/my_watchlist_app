import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_plugin/my_auth_plugin.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _submitAuthForm() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthPluginProvider>(
      context,
      listen: false,
    );
    String? result;

    try {
      if (_isLogin) {
        result = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        result = await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _errorMessage = result;
          _isLoading = false;
        });
      } else {}
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ocorreu um erro: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Icon(
                    _isLogin ? Icons.lock : Icons.person_add,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Seja bem vindo(a)' : 'Crie sua conta',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Faça login para continuar'
                        : 'Cadastre-se para começar a usar',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu.email@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitAuthForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          _isLogin ? 'Entrar' : 'Criar Conta',
                          style: const TextStyle(fontSize: 18),
                        ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  _isLogin
                      ? 'Não tem uma conta? Registre-se!'
                      : 'Já tem uma conta? Faça login!',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
