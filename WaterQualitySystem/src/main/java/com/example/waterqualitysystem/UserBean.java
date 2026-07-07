package com.example.waterqualitysystem;

import java.io.Serializable;

/**
 * 用户信息JavaBean
 * Jakarta EE课程要求：JSP+Servlet+JavaBean三层结构
 */
public class UserBean implements Serializable {

    private int id;
    private String username;
    private String password;
    private String email;
    private String phone;
    private String qq;
    private String realName;
    private int roleId;
    private String roleName;
    private String createTime;
    private String lastLoginTime;
    private int status;

    public UserBean() {}

    public UserBean(int id, String username, String email, String phone,
                    String qq, String realName, int roleId, String roleName,
                    String createTime, String lastLoginTime, int status) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.phone = phone;
        this.qq = qq;
        this.realName = realName;
        this.roleId = roleId;
        this.roleName = roleName;
        this.createTime = createTime;
        this.lastLoginTime = lastLoginTime;
        this.status = status;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getQq() { return qq; }
    public void setQq(String qq) { this.qq = qq; }

    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }

    public String getLastLoginTime() { return lastLoginTime; }
    public void setLastLoginTime(String lastLoginTime) { this.lastLoginTime = lastLoginTime; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    @Override
    public String toString() {
        return "UserBean{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", realName='" + realName + '\'' +
                ", roleName='" + roleName + '\'' +
                '}';
    }
}