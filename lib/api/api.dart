import 'package:dio/dio.dart';
import 'package:partido_client/model/bill.dart';
import 'package:partido_client/model/group.dart';
import 'package:partido_client/model/group_join_body.dart';
import 'package:partido_client/model/new_user.dart';
import 'package:partido_client/model/report.dart';
import 'package:partido_client/model/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api.g.dart';

@RestApi(baseUrl: "https://fosforito.net:8090/")
abstract class Api {
  factory Api(Dio dio) = _Api;

  @POST("/login")
  @MultiPart()
  Future<HttpResponse<String>> login(
      @Part(name: "username") String username,
      @Part(name: "password") String password,
      @Part(name: "remember-me") String rememberMe);

  @POST("/logout")
  Future<HttpResponse<String>> logout();

  @POST("/users")
  Future<HttpResponse<User>> register(@Body() NewUser data);

  @PUT("/users/{userId}")
  Future<HttpResponse<User>> updateUser(@Body() NewUser user, @Path("userId") int userId);

  @GET("/currentuser")
  Future<User> getCurrentUser();

  @GET("/currentuser")
  Future<HttpResponse<User>> getLoginStatus();

  @GET("/currentusergroups")
  Future<List<Group>> getMyGroups();

  @POST("/groups/")
  Future<HttpResponse<Group>> createGroup(@Body() Group group);

  @PUT("/groups/{groupId}")
  Future<HttpResponse<Group>> updateGroup(@Path("groupId") int groupId, @Body() Group group);

  @GET("/groups/{groupId}")
  Future<Group> getGroup(@Path("groupId") int groupId);

  @POST("/groups/{groupId}/join")
  Future<HttpResponse<String>> joinGroup(@Path("groupId") int groupId, @Body() GroupJoinBody groupJoinBody);

  @GET("/groups/{groupId}/bills")
  Future<List<Bill>> getBillsForGroup(@Path("groupId") int groupId);

  @POST("/groups/{groupId}/bills")
  Future<HttpResponse<Bill>> createBill(@Body() Bill bill, @Path("groupId") int groupId);

  @PUT("/groups/{groupId}/bills/{billId}")
  Future<HttpResponse<Bill>> updateBill(@Body() Bill bill, @Path("groupId") int groupId, @Path("billId") int billId);

  @DELETE("/bills/{billId}")
  Future<HttpResponse<String>> deleteBill(@Path("billId") int billId);

  @GET("/groups/{groupId}/report")
  Future<Report> getReportForGroup(@Path("groupId") int groupId);
}
