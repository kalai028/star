import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_star/Provider/repository_provider.dart';
import 'package:git_star/Models/repository_model.dart';
import 'package:git_star/Widgets/repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  //Scroll Controller
  final _scrollController = ScrollController();

  //For checking network connection status
  List<ConnectivityResult> connectionStatus = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    //If mobile has network connection, it will fetch data from server. Otherwise, It will fetch data from local database
    _checkConnectionAndLoadData();

    //Adding listener for pagination
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _checkConnectionAndLoadData() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (event) {
        connectionStatus = event;
        initialize();
      },
    );
  }

  //Function for fetching data
  void initialize() async {
    //To show the loading widget while fetching data
    ref.read(repositoryProvider.notifier).showLoader = true;
    //Page number is set to be 0, when fetching data from scratch
    ref.read(repositoryProvider.notifier).currentPage = 0;
    //Fetching data via provider
    await ref.read(repositoryProvider.notifier).fetchData(context,
        hasInternet: !connectionStatus.contains(ConnectivityResult.none));
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (!connectionStatus.contains(ConnectivityResult.none)) {
        //when the user reaches the bottom of the screen, the data will fetched from server only if the data connection is enabled.
        //Because If the user has no connection, the data will be fetch from local database only.
        //Once we fetch data from local db, all data will be listed. So no pagination needed for local database
        ref.read(repositoryProvider.notifier).fetchDataFromServer(context);
      }
    }
  }

  @override
  void dispose() {
    //Canceling the subscription when dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Provider for showing github repositories list
    List<RepositoryModel> repositories = ref.watch(repositoryProvider);

    //To show loading widget
    bool isLoading = ref.watch(
        repositoryProvider.notifier.select((notifier) => notifier.showLoader));

    //To indicate the user if error occurs
    String? error = ref.watch(
        repositoryProvider.notifier.select((notifier) => notifier.error));

    return Scaffold(
      backgroundColor: const Color(0xFFf1f2f6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2f3542),
        title: const Text(
          'Popular Repositories',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  if (!connectionStatus.contains(ConnectivityResult.none)) {
                    //To get most starred repositories that were created in last 60 days
                    ref.read(repositoryProvider.notifier).daysAgo = 60;
                    //Again recollecting data
                    initialize();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please connect to the network'),
                      ),
                    );
                  }
                },
                child: const Text('Last 60 days only'),
              ),
              PopupMenuItem(
                onTap: () {
                  if (!connectionStatus.contains(ConnectivityResult.none)) {
                    //To get most starred repositories that were created in last 30 days
                    ref.read(repositoryProvider.notifier).daysAgo = 30;
                    //Again recollecting data
                    initialize();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please connect to the network'),
                      ),
                    );
                  }
                },
                child: const Text('Last 30 days only'),
              )
            ],
          )
        ],
      ),
      body: error != null
          ? Center(child: Text(error))
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : repositories.isEmpty
                  ? Center(
                      child: TextButton.icon(
                        onPressed: initialize,
                        label: const Text('Refresh'),
                        icon: const Icon(Icons.refresh),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: repositories.length,
                            itemBuilder: (context, index) => Repo(
                              repository: repositories[index],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
