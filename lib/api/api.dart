import 'package:dio/dio.dart';
import 'package:partido_client/model/remote/checkout_report.dart';
import 'package:partido_client/model/remote/entry.dart';
import 'package:partido_client/model/remote/group.dart';
import 'package:partido_client/model/remote/group_join_body.dart';
import 'package:partido_client/model/remote/new_user.dart';
import 'package:partido_client/model/remote/report.dart';
import 'package:partido_client/model/remote/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api.g.dart';

@RestApi(baseUrl: "https://partido.rocks/api/")
abstract class Api {
  factory Api(Dio dio) = _Api;

  @POST("/login")
  @MultiPart()
  Future<HttpResponse<String>> login(
    @Part(name: "username") String username,
    @Part(name: "password") String password,
    @Part(name: "remember-me") String rememberMe,
  );

  @POST("/logout")
  Future<HttpResponse<String>> logout();

  @POST("/users")
  Future<HttpResponse<User>> register(
    @Body() NewUser data,
  );

  @PUT("/users/{userId}")
  Future<HttpResponse<User>> updateUser(
    @Body() NewUser user,
    @Path("userId") int userId,
  );

  @DELETE("/users/{userId}")
  Future<HttpResponse<String>> deleteUser(
    @Path("userId") int userId,
  );

  @GET("/currentuser")
  Future<User> getCurrentUser();

  @GET("/currentuser")
  Future<HttpResponse<User>> getLoginStatus();

  @GET("/currentusergroups")
  Future<List<Group>> getMyGroups();

  @POST("/groups/")
  Future<HttpResponse<Group>> createGroup(
    @Body() Group group,
  );

  @PUT("/groups/{groupId}")
  Future<HttpResponse<Group>> updateGroup(
    @Path("groupId") int groupId,
    @Body() Group group,
  );

  @GET("/groups/{groupId}")
  Future<Group> getGroup(
    @Path("groupId") int groupId,
  );

  @POST("/groups/{groupId}/join")
  Future<HttpResponse<String>> joinGroup(
    @Path("groupId") int groupId,
    @Body() GroupJoinBody groupJoinBody,
  );

  @POST("/groups/{groupId}/leave")
  Future<HttpResponse<String>> leaveGroup(
    @Path("groupId") int groupId,
  );

  @GET("/groups/{groupId}/bills")
  Future<List<Entry>> getEntriesForGroup(
    @Path("groupId") int groupId,
  );

  @POST("/groups/{groupId}/bills")
  Future<HttpResponse<Entry>> createEntry(
    @Body() Entry entry,
    @Path("groupId") int groupId,
  );

  @PUT("/groups/{groupId}/bills/{billId}")
  Future<HttpResponse<Entry>> updateEntry(
    @Body() Entry entry,
    @Path("groupId") int groupId,
    @Path("billId") int billId,
  );

  @DELETE("/bills/{billId}")
  Future<HttpResponse<String>> deleteEntry(
    @Path("billId") int billId,
  );

  @GET("/groups/{groupId}/report")
  Future<Report> getReportForGroup(
    @Path("groupId") int groupId,
  );

  @POST("/groups/{groupId}/checkout")
  Future<HttpResponse<CheckoutReport>> checkoutGroup(
    @Path("groupId") int groupId,
  );
}
