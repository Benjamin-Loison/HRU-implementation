# HRU implementation
Implementation based on "Protection in operating systems" Michael A. Harrison, Walter L. Ruzzo and Jeffrey D. Ullman 1976 (https://dl.acm.org/doi/abs/10.1145/360303.360333). We name HRU this article.

Because as proven in HRU the common case of multiple operations per command is undecidable, we just proceed by bruteforce.

The final aim is to find automatically an attack on our modelisation of Android permission system which has Pileup attack. Pileup attack is defined in this article: "Upgrading Your Android, Elevating My Malware: Privilege Escalation through Mobile OS Updating" Luyi Xing, Xiaorui Pan, Rui Wang, Kan Yuan, and XiaoFeng Wang 2014 (https://ieeexplore.ieee.org/document/6956577).
Adding other modelisations of known attacks will make our algorithm more efficient.
