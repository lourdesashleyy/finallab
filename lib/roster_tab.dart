import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RosterTab extends StatelessWidget {
  final String username; // this is the team ID

  const RosterTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final teamDoc = FirebaseFirestore.instance.collection('tbl_teams').doc(username);

    return FutureBuilder<DocumentSnapshot>(
      future: teamDoc.get(),
      builder: (context, teamSnapshot) {
        if (teamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!teamSnapshot.hasData || !teamSnapshot.data!.exists) {
          return const Center(child: Text('Team not found.'));
        }

        final teamName = teamSnapshot.data!.get('teamName') ?? 'Team Roster';

        return FutureBuilder<QuerySnapshot>(
          future: teamDoc.collection('players').get(),
          builder: (context, playerSnapshot) {
            if (playerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!playerSnapshot.hasData || playerSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No players found.'));
            }

            final players = playerSnapshot.data!.docs;

            return Scaffold(
              backgroundColor: Colors.grey.shade100,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      teamName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        itemCount: players.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2 / 3,
                        ),
                        itemBuilder: (context, index) {
                          final player = players[index].data() as Map<String, dynamic>;
                          return PlayerCard(
                            name: player['name'] ?? 'No Name',
                            nickname: player['nickname'] ?? '',
                            position: player['position'] ?? '',
                            number: player['number'] ?? '',
                            imageUrl: player['imageUrl'] ?? '',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PlayerCard extends StatelessWidget {
  final String name;
  final String nickname;
  final String position;
  final String number;
  final String imageUrl;

  const PlayerCard({
    super.key,
    required this.name,
    required this.nickname,
    required this.position,
    required this.number,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B4C),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 36, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                nickname,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(), // pushes badge to bottom
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      position,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
