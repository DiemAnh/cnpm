class ApiConstants {
  static const baseUrl = 'http://10.0.2.2:9090';

  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const apartments = '/api/apartments/list';
  static const users = '/api/admin/users';
  static const profile = '/api/user/home';
  static const adminAddApartment =
      '/api/admin/apartment-list/add-apartment';
  static const adminEditApartment = '/api/admin/apartment-list/edit-apartment';
  static String adminGetApartmentById(String id) =>
      '/api/admin/apartment-list/edit-apartment/$id';
  static const String deleteApartment =
      "/api/admin/apartment-list/delete";
  static const bills = '/api/admin/bills';
  static const addBill = '/api/admin/bills';
  static const editBill = '/api/admin/bills/edit'; // + /{id}
  static const deleteBill = '/api/admin/bills'; // + /{id}
  static const deleteUser = '/api/admin/users/delete'; // + /{id}
  static const editUser = '/api/admin/users/edit'; // + /{id}
  static const addUser = '/api/admin/users/add';

}
