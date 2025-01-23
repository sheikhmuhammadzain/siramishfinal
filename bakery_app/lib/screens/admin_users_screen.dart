import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
	const AdminUsersScreen({super.key});

	@override
	State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
	List<Map<String, dynamic>> _users = [];
	bool _isLoading = true;
	late final ApiService _apiService;

	@override
	void initState() {
		super.initState();
		_apiService = ApiService(context);
		_loadUsers();
	}

	Future<void> _loadUsers() async {
		try {
			final users = await _apiService.getUsers();
			setState(() {
				_users = users;
				_isLoading = false;
			});
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error loading users: $e')),
			);
			setState(() => _isLoading = false);
		}
	}

	Future<void> _showAddEditUserDialog(BuildContext context, [Map<String, dynamic>? user]) async {
		final usernameController = TextEditingController(text: user?['username']);
		final emailController = TextEditingController(text: user?['email']);
		String selectedRole = user?['is_staff'] == true ? 'admin' : 'user';

		await showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: Text(user == null ? 'Add User' : 'Edit User'),
				content: SingleChildScrollView(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextField(
								controller: usernameController,
								decoration: const InputDecoration(labelText: 'Username'),
							),
							TextField(
								controller: emailController,
								decoration: const InputDecoration(labelText: 'Email'),
								keyboardType: TextInputType.emailAddress,
							),
							const SizedBox(height: 16.0),
							DropdownButtonFormField<String>(
								value: selectedRole,
								decoration: const InputDecoration(labelText: 'Role'),
								items: ['user', 'admin'].map((role) {
									return DropdownMenuItem(
										value: role,
										child: Text(role.toUpperCase()),
									);
								}).toList(),
								onChanged: (value) {
									selectedRole = value!;
								},
							),
						],
					),
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(ctx).pop(),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () async {
							try {
								final userData = {
									'username': usernameController.text,
									'email': emailController.text,
									'is_staff': selectedRole == 'admin',
								};

								if (user == null) {
									await _apiService.createUser(userData);
								} else {
									await _apiService.updateUser(user['id'], userData);
								}

								if (!mounted) return;
								Navigator.of(ctx).pop();
								_loadUsers(); // Refresh the users list
								ScaffoldMessenger.of(context).showSnackBar(
									SnackBar(
										content: Text(
											user == null
													? 'User created successfully'
													: 'User updated successfully',
										),
									),
								);
							} catch (e) {
								if (!mounted) return;
								ScaffoldMessenger.of(context).showSnackBar(
									SnackBar(content: Text('Error: $e')),
								);
							}
						},
						child: const Text('Save'),
					),
				],
			),
		);
	}

	Future<void> _deleteUser(Map<String, dynamic> user) async {
		try {
			await _apiService.deleteUser(user['id']);
			setState(() {
				_users.removeWhere((u) => u['id'] == user['id']);
			});
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('User deleted successfully')),
			);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error deleting user: $e')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Manage Users'),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _showAddEditUserDialog(context),
				child: const Icon(Icons.add),
			),
			body: _isLoading
					? const Center(child: CircularProgressIndicator())
					: ListView.builder(
							itemCount: _users.length,
							itemBuilder: (ctx, index) {
								final user = _users[index];
								return Card(
									margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
									child: ListTile(
										leading: CircleAvatar(
											child: Text(user['username'][0].toUpperCase()),
										),
										title: Text(user['username']),
										subtitle: Text(user['email']),
										trailing: Row(
											mainAxisSize: MainAxisSize.min,
											children: [
												Switch(
													value: user['is_active'] ?? true,
													onChanged: (value) async {
														try {
															await _apiService.updateUser(
																user['id'],
																{...user, 'is_active': value},
															);
															_loadUsers();
														} catch (e) {
															if (!mounted) return;
															ScaffoldMessenger.of(context).showSnackBar(
																SnackBar(content: Text('Error: $e')),
															);
														}
													},
												),
												IconButton(
													icon: const Icon(Icons.edit),
													onPressed: () => _showAddEditUserDialog(context, user),
												),
												IconButton(
													icon: const Icon(Icons.delete),
													onPressed: () => _deleteUser(user),
												),
											],
										),
									),
								);
							},
						),
		);
	}
}