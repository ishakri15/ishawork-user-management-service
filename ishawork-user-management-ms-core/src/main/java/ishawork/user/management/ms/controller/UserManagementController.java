package ishawork.user.management.ms.controller;

import ishawork.user.management.ms.model.NewUser;
import ishawork.user.management.ms.model.User;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserManagementController implements UsersApiDelegate{
    @Override
    public ResponseEntity<User> createUser(NewUser newUser) {
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);
    }

}
