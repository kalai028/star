import 'package:flutter/material.dart';
import 'package:git_star/Models/repository_model.dart';
import 'package:google_fonts/google_fonts.dart';

class Repo extends StatelessWidget {
  const Repo({super.key, required this.repository});

  final RepositoryModel repository;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          //Header - Repository name, star counts
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      child: Image.asset(
                        'assets/images/github.png',
                      ),
                    ),
                    const SizedBox(width: 7.5),
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: Text(
                        repository.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      repository.starCount.toString(),
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
          //Owner profile and repository description
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.36,
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.network(
                          repository.ownerAvatarLink,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.wifi_off,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        repository.ownerName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Owner',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        repository.description,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
