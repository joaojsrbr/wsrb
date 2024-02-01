// import 'package:flutter/material.dart';

// const brow = Color.fromRGBO(89, 87, 76, 10);

// class MyApp2 extends StatelessWidget {
//   const MyApp2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Garamond',
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ButtonStyle(
//             elevation: const MaterialStatePropertyAll(1),
//             shape: MaterialStatePropertyAll(
//               RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//             backgroundColor: const MaterialStatePropertyAll(brow),
//             textStyle: const MaterialStatePropertyAll(
//               TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//               ),
//             ),
//           ),
//         ),
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     bool isHover = false;
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           padding: EdgeInsets.zero,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const SizedBox(
//                     height: 32,
//                   ),
//                   // Image.asset(
//                   //   'assets/default-placeholder.png',
//                   //   fit: BoxFit.contain,
//                   //   height: 32,
//                   // ),
//                   const SizedBox(width: 10),
//                   Text(
//                     'John Doe Arquitetura',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w400,
//                       color: brow,
//                       fontSize: size.width * 0.05,
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 5),
//                 child: Flexible(
//                   fit: FlexFit.tight,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: 40,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 5,
//                           vertical: 10,
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'Home',
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 40,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 5,
//                           vertical: 10,
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'Projetos',
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 40,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 5,
//                           vertical: 10,
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'Contato',
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: const Center(
//         child: Text('Sobre'),
//       ),
//     );
//   }
// }
