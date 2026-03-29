import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmed/models/post.dart';
import 'package:sosmed/models/user.dart';

class ApiService {
  final dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8081/api",
    sendTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20)
  ));

  ApiService(){
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async{
        final key = await SharedPreferences.getInstance();
        final token = key.getString('token');
        
        if(token != null){
          options.headers['Authorization'] = "Bearer $token";
        }
        handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>> login(String email, String password)async{
    try{
      final response = await dio.post("/login", data: {
        "email": email,
        "password": password
      });

      if(response.statusCode == 200 && response.data['success'] == true){
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool("statusLogin", true);
      }

      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message']
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String? bio, String? profilePath)async{
    MultipartFile? profile;
    if(profilePath != null){
       profile = await MultipartFile.fromFile(profilePath);
    }
    try{
      final request = FormData.fromMap({
        "name": name,
        "email": email,
        "password": password,
        if(bio != null)
        "bio": bio,
        if(profile != null)
        "profile": profile
      });
      
      final response = await dio.post('/register', data: request);
      if(response.statusCode == 201 && response.data['success'] == true){
        final key = await SharedPreferences.getInstance();
        await key.setString("token", response.data['data']['token']);
        await key.setBool("statusLogin", true);
      }

      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response?.data['message']
      };
    }
  }

  Future<void> logout()async{
    final key = await SharedPreferences.getInstance();
    try{
      await dio.post("/logout");
      await key.remove("token");
      await key.remove("statusLogin");
      return;
    }on DioException catch(e){
      await key.remove("token");
      await key.remove("statusLogin");
      return;
    }
  }

  Future<User> currentUser({String? page})async{
    try{
      final response = await dio.get("/user?page=$page");
      return User.fromJson(response.data);
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<User> showUser({required int userId, String? page})async{
    try{
      final response = await dio.get("/user/$userId?page=$page");
      return User.fromJson(response.data['data']);
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> updateUser(int userId, String name, String email, String bio, String? profilePath)async{
    MultipartFile? profileFile;
    if(profilePath != null){
      profileFile = await MultipartFile.fromFile(profilePath);
    }

    try{
      final request = FormData.fromMap({
        "_method": "PUT",
        "name": name,
        "email": email,
        if(bio.isNotEmpty)
        "bio": bio,
        if(profileFile != null)
        "profile": profileFile
      });
      final response = await dio.post("/user/$userId", data: request);
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response.toString()
      };
    }
  }

  Future<List<Post>> showAllPostUser(int userId, String page)async{
    try{
      final response = await dio.get("/user/post/$userId?page=$page");
      return(response.data['data'] as List).map((item) => Post.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<List<Post>> getAllPost()async{
    try{
      final response = await dio.get("/post");
      return (response.data['data'] as List).map((item) => Post.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<List<Post>> getAllReels()async{
    try{
      final response = await dio.get("/reels");
      return(response.data['data'] as List).map((item) => Post.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Post> showPost(int postId)async{
    try{
      final response = await dio.get("/post/$postId");
      return Post.fromJson(response.data['data']);
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> uploadPost(String caption, String type, List<String> imagePath, String? videoPath, String? thumbnailPath)async{
    List<MultipartFile> imageFile = [];
    MultipartFile? videoFile;
    MultipartFile? thumbnailFile;
    if(imagePath.isNotEmpty){
      for(var image in imagePath){
        imageFile.add(await MultipartFile.fromFile(image));
      }
    }

    if(thumbnailPath != null){
      thumbnailFile = await MultipartFile.fromFile(thumbnailPath);
    }
    
    if(videoPath != null){
      videoFile = await MultipartFile.fromFile(videoPath);
    }

    try{
      final request = FormData.fromMap({
        "caption": caption,
        "type": type,
        if(imageFile.isNotEmpty)
        "image[]": imageFile,
        if(thumbnailFile != null)
        "thumbnail": thumbnailFile,
        if(videoFile != null)
        "video": videoFile
      });

      final response = await dio.post("/post", data: request);
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response.toString()
      };
    }
  }

  Future<Map<String, dynamic>> reactPost(int postId)async{
    try{
      final response = await dio.put("/reaction/$postId");
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response.toString()
      };
    }
  }

  Future<Map<String, dynamic>> following(int userId)async{
    try{
      final response = await dio.put("/follow/$userId");
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response.toString()
      };
    }
  }

  Future<Map<String, dynamic>> sendComment(int postId, String message)async{
    try{
      final response = await dio.post('/comment', data: {
        "post_id": postId,
        "message": message
      });
      return response.data;
    }on DioException catch(e){
      return {
        "success": false,
        "message": e.response
      };
    }
  }

  Future<List<User>> getAllChat()async{
    try{
      final response = await dio.get('/message');
      return(response.data['data'] as List).map((item) => User.fromJson(item)).toList();
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }

  Future<Map<String, dynamic>> getAllMessage(int receiverId)async{
    try{
      final response = await dio.get("/message/$receiverId");
      return response.data;
    }on DioException catch(e){
      return{
        "success": false,
        "message": e.response
      };
    }
  }

  Future<void> sendMessage(int receiverId, String message, String? imagePath)async{
    try{
      MultipartFile? imageFile;
      if(imagePath != null){
        imageFile = await MultipartFile.fromFile(imagePath);
      }
      
      final request = FormData.fromMap({
        "receiver_id": receiverId,
        "message": message,
        if(imagePath != null)
        "image": imageFile
      });
      final response = await dio.post("/message", data: request);
      print("Data: ${response.data}");
      return;
    }on DioException catch(e){
      print(e.response);
      return;
    }
  }

  Future<void> updateMessage(int messageId, String message, String? imagePath)async{
    try{
      MultipartFile? imageFile;
      if(imagePath != null){
        imageFile = await MultipartFile.fromFile(imagePath);
      }
      
      final request = FormData.fromMap({
        "_method": "PUT",
        "message": message,
        if(imagePath != null)
        "image": imageFile
      });
      final response = await dio.post("/message/$messageId", data: request);
      print("Data: ${response.data}");
      return;
    }on DioException catch(e){
      print(e.response);
      return;
    }
  }

  Future<void> deleteMessage(int messageId)async{
    try{
      final response = await dio.delete("/message/$messageId");
      print("Data: ${response.data}");
    }on DioException catch(e){
      print(e.response);
    }
  }

  Future<Map<String, dynamic>> authBroadcast(String? socketId, String channelName)async{
    try{
      final response = await dio.post("/broadcasting/auth", data: {
        "socket_id": socketId,
        "channel_name": channelName
      });

      return response.data;
    }on DioException catch(e){
      throw Exception(e.response);
    }
  }
}