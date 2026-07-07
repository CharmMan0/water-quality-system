<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">

    <div class="container-fluid">

        <a class="navbar-brand fw-bold" href="dashboard">
            Water Quality AI
        </a>

        <button class="navbar-toggler"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarNav">

            <span class="navbar-toggler-icon"></span>

        </button>

        <div class="collapse navbar-collapse" id="navbarNav">

            <ul class="navbar-nav me-auto">

                <li class="nav-item">
                    <a class="nav-link" href="dashboard">
                        Dashboard
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="index.jsp">
                        New Detection
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="history">
                        History
                    </a>
                </li>

            </ul>

            <span class="navbar-text text-white me-3">
                Welcome,
                <%= session.getAttribute("username") %>
            </span>

            <a href="logout"
               class="btn btn-danger btn-sm">
                Logout
            </a>

        </div>

    </div>

</nav>