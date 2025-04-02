import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/paginator.dart';
import 'package:wiretap_webclient/component/state_manager/widgets/bloc_provider.dart';
import 'package:wiretap_webclient/presentation/account/account_cubit.dart';
import 'package:wiretap_webclient/repo/ui/ui_repo.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  static const String path = '/account';
  static const String name = 'account';
  static const String label = 'Account';
  static const IconData icon = Icons.account_circle;

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    final isInitialized = AccountCubit().state.isInitialized;
    if (!isInitialized) {
      AccountCubit().init();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = BlocProvider.of<AccountCubit>(context).state;
    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const ListTile(
            title: Text('Account'),
            subtitle: Text('Account settings for WireTap'),
            leading: Icon(Icons.account_circle),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 32,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        boxShadow: [BoxShadow(blurRadius: 32, spreadRadius: 2)],
                      ),
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text('Account Information'),
                            subtitle: Text('Your account information'),
                            leading: Icon(Icons.info),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Username: '),
                              Flexible(child: Text(state.user?.username ?? 'N/A')),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Alias: '),
                              Flexible(child: Text(state.user?.alias ?? 'N/A')),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Admin Privileges: '),
                              Flexible(child: Text(state.user?.isAdmin == true ? 'Yes' : 'No')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        boxShadow: [BoxShadow(blurRadius: 32, spreadRadius: 2)],
                      ),
                      child: Column(
                        children: [
                          SearchBar(
                            controller: searchController,
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.search),
                            ),
                            hintText: 'Search users',
                            onSubmitted: (value) {
                              BlocProvider.of<AccountCubit>(
                                context,
                              ).searchUser(state.page, searchParam: value);
                            },
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.data.length,
                              itemBuilder: (context, index) {
                                final user = state.data[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      user.username.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    user.alias != null
                                        ? '${user.alias} - ${user.username}'
                                        : user.username,
                                  ),
                                  subtitle: Text(
                                    'Admin Privileges: ${user.isAdmin ? 'Yes' : 'No'}',
                                  ),
                                  trailing: Column(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          UiRepo().showConfirmDialog(
                                            context,
                                            'Are you sure you want to delete this user?',
                                            title: 'Delete User',
                                            onConfirm: () {
                                              BlocProvider.of<AccountCubit>(
                                                context,
                                              ).deleteUser(user.id);
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Paginator(
                            totalPage: state.totalPage,
                            currentPage: state.page,
                            onPageChanged: (page) {
                              BlocProvider.of<AccountCubit>(
                                context,
                              ).searchUser(page, searchParam: searchController.text);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
