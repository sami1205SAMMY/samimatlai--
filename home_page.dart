import 'package:show_app_backend/config/api_config.dart';
import 'package:show_app_backend/screens/add_show_page.dart';
import 'package:show_app_backend/screens/profile_page.dart';
import 'package:show_app_backend/screens/update_show_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> movies = [];
  List<dynamic> anime = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShows();
  }

  Future<void> fetchShows() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/shows'));

      if (response.statusCode == 200) {
        List<dynamic> allShows = jsonDecode(response.body);

        setState(() {
          movies = allShows.where((show) => show['category'] == 'movie').toList();
          anime = allShows.where((show) => show['category'] == 'anime').toList();
          series = allShows.where((show) => show['category'] == 'serie').toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> deleteShow(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/shows/$id'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Show deleted successfully")),
        );
        fetchShows(); // Refresh list after deletion
      } else {
        throw Exception('Failed to delete show');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Show"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteShow(id);
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return ShowList(shows: movies, onDelete: confirmDelete);
      case 1:
        return ShowList(shows: anime, onDelete: confirmDelete);
      case 2:
        return ShowList(shows: series, onDelete: confirmDelete);
      default:
        return const Center(child: Text("Unknown Page"));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show App"), 
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchShows,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddShowPage()),
                ).then((value) {
                  if (value == true) {
                    fetchShows(); // Refresh after adding
                  }
                });
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchShows,
        child: _getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ShowList extends StatelessWidget {
  final List<dynamic> shows;
  final Function(int) onDelete;

  const ShowList({super.key, required this.shows, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) {
      return const Center(
        child: Text("No Shows Available", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: shows.length,
      itemBuilder: (context, index) {
        final show = shows[index];
        return Dismissible(
          key: Key(show['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDelete(show['id']),
          confirmDismiss: (direction) async {
            final result = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Delete Show"),
                content: const Text("Are you sure you want to delete this show?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            return result;
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: show['image'] != null
                  ? Image.network(
                      ApiConfig.baseUrl + show['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.movie, size: 50),
              title: Text(show['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(show['description']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateShowPage(show: show),
                  ),
                ).then((value) {
                  if (value == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Show updated successfully")),
                    );
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}