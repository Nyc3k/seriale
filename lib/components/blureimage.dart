import 'dart:ui';

import 'package:flutter/material.dart';

class BlureImage extends StatelessWidget {
  final String imageURL;
  const BlureImage({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageURL,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    color: Colors.transparent
                                  ),
                                ),
                              ),
                            ),
                            Image.network(
                              imageURL,
                              fit: BoxFit.contain,
                            ),
                            Expanded(
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              );
  }
}