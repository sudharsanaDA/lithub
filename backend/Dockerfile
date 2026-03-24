FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# ─── Create pom.xml ───────────────────────────────────────────────
RUN cat > pom.xml << 'POMEOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version>
    <relativePath/>
  </parent>
  <groupId>com.lithub</groupId>
  <artifactId>lithub-backend</artifactId>
  <version>1.0.0</version>
  <properties>
    <java.version>17</java.version>
    <jjwt.version>0.11.5</jjwt.version>
  </properties>
  <dependencies>
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-security</artifactId></dependency>
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
    <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-mail</artifactId></dependency>
    <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-api</artifactId><version>${jjwt.version}</version></dependency>
    <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-impl</artifactId><version>${jjwt.version}</version><scope>runtime</scope></dependency>
    <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-jackson</artifactId><version>${jjwt.version}</version><scope>runtime</scope></dependency>
    <dependency><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId><optional>true</optional></dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude><groupId>org.projectlombok</groupId><artifactId>lombok</artifactId></exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
POMEOF

# ─── Create folder structure ──────────────────────────────────────
RUN mkdir -p src/main/java/com/lithub/entity \
             src/main/java/com/lithub/repository \
             src/main/java/com/lithub/service \
             src/main/java/com/lithub/controller \
             src/main/java/com/lithub/dto \
             src/main/java/com/lithub/config \
             src/main/java/com/lithub/security \
             src/main/java/com/lithub/exception \
             src/main/resources

# ─── application.properties ──────────────────────────────────────
RUN cat > src/main/resources/application.properties << 'EOF'
server.port=8080
spring.datasource.url=${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/lithub}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME:postgres}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD:password}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=${SPRING_JPA_HIBERNATE_DDL_AUTO:update}
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
lithub.jwt.secret=${LITHUB_JWT_SECRET:lithub_secret_key_256bits_minimum_length_here}
lithub.jwt.expiration=${LITHUB_JWT_EXPIRATION:86400000}
lithub.cors.allowed-origins=${LITHUB_CORS_ALLOWED_ORIGINS:http://localhost:3000}
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=${SPRING_MAIL_USERNAME:}
spring.mail.password=${SPRING_MAIL_PASSWORD:}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
logging.level.com.lithub=INFO
EOF

# ─── Main Application ─────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/LitHubApplication.java << 'EOF'
package com.lithub;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class LitHubApplication {
    public static void main(String[] args) {
        SpringApplication.run(LitHubApplication.class, args);
    }
}
EOF

# ─── User Entity ──────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/entity/User.java << 'EOF'
package com.lithub.entity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true, nullable = false, length = 50)
    private String username;
    @Column(unique = true, nullable = false)
    private String email;
    @Column(nullable = false)
    private String password;
    private String nickname;
    private String gender;
    private Integer age;
    @Column(columnDefinition = "TEXT")
    private String bio;
    @Column(name = "is_verified")
    @Builder.Default
    private Boolean isVerified = false;
    @Column(name = "otp_code", length = 6)
    private String otpCode;
    @Column(name = "otp_expires_at")
    private LocalDateTime otpExpiresAt;
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Role role = Role.USER;
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    public enum Role { USER, ADMIN }
}
EOF

# ─── Book Entity ──────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/entity/Book.java << 'EOF'
package com.lithub.entity;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "books")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String title;
    @Column(nullable = false)
    private String author;
    @Column(columnDefinition = "TEXT")
    private String description;
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;
    private String genre;
    private String language;
    private Integer pages;
    private Integer year;
    private Double rating;
    @Column(name = "cover_url")
    private String coverUrl;
    @Column(name = "stock_count")
    @Builder.Default
    private Integer stockCount = 0;
    @Column(name = "is_ebook")
    @Builder.Default
    private Boolean isEbook = false;
    @Column(name = "is_bestseller")
    @Builder.Default
    private Boolean isBestseller = false;
    @Column(name = "is_new_arrival")
    @Builder.Default
    private Boolean isNewArrival = false;
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private BookCondition condition = BookCondition.NEW;
    private LocalDateTime createdAt;
    public enum BookCondition { NEW, USED }
}
EOF

# ─── DTOs ─────────────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/dto/RegisterRequest.java << 'EOF'
package com.lithub.dto;
import jakarta.validation.constraints.*;
import lombok.Data;
@Data
public class RegisterRequest {
    @NotBlank private String username;
    @NotBlank @Size(min = 8) private String password;
    @NotBlank @Email private String email;
    private String nickname;
    private String gender;
    private Integer age;
}
EOF

RUN cat > src/main/java/com/lithub/dto/LoginRequest.java << 'EOF'
package com.lithub.dto;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
@Data
public class LoginRequest {
    @NotBlank private String usernameOrEmail;
    @NotBlank private String password;
}
EOF

RUN cat > src/main/java/com/lithub/dto/OtpRequest.java << 'EOF'
package com.lithub.dto;
import lombok.Data;
@Data
public class OtpRequest {
    private String email;
    private String otp;
}
EOF

RUN cat > src/main/java/com/lithub/dto/AuthResponse.java << 'EOF'
package com.lithub.dto;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AuthResponse {
    private String token;
    private String tokenType;
    private UserResponse user;
}
EOF

RUN cat > src/main/java/com/lithub/dto/UserResponse.java << 'EOF'
package com.lithub.dto;
import lombok.*;
import java.time.LocalDateTime;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class UserResponse {
    private Long id;
    private String username;
    private String email;
    private String nickname;
    private Boolean isVerified;
    private String role;
    private LocalDateTime createdAt;
}
EOF

RUN cat > src/main/java/com/lithub/dto/ApiResponse.java << 'EOF'
package com.lithub.dto;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    public static <T> ApiResponse<T> success(T data, String message) {
        return ApiResponse.<T>builder().success(true).message(message).data(data).build();
    }
    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder().success(false).message(message).build();
    }
}
EOF

RUN cat > src/main/java/com/lithub/dto/BookResponse.java << 'EOF'
package com.lithub.dto;
import lombok.*;
import java.math.BigDecimal;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class BookResponse {
    private Long id;
    private String title;
    private String author;
    private String description;
    private BigDecimal price;
    private String genre;
    private String language;
    private Integer pages;
    private Integer year;
    private Double rating;
    private String coverUrl;
    private Integer stockCount;
    private Boolean isEbook;
    private Boolean isBestseller;
    private Boolean isNewArrival;
    private String condition;
}
EOF

# ─── Repository ───────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/repository/UserRepository.java << 'EOF'
package com.lithub.repository;
import com.lithub.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByUsernameOrEmail(String username, String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
EOF

RUN cat > src/main/java/com/lithub/repository/BookRepository.java << 'EOF'
package com.lithub.repository;
import com.lithub.entity.Book;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
@Repository
public interface BookRepository extends JpaRepository<Book, Long> {
    @Query("SELECT b FROM Book b WHERE " +
           "(:search IS NULL OR LOWER(b.title) LIKE LOWER(CONCAT('%',:search,'%')) OR LOWER(b.author) LIKE LOWER(CONCAT('%',:search,'%'))) AND " +
           "(:genre IS NULL OR LOWER(b.genre) = LOWER(:genre)) AND " +
           "(:isEbook IS NULL OR b.isEbook = :isEbook) AND " +
           "(:isBestseller IS NULL OR b.isBestseller = :isBestseller) AND " +
           "(:isNewArrival IS NULL OR b.isNewArrival = :isNewArrival)")
    Page<Book> findWithFilters(@Param("search") String search,
                               @Param("genre") String genre,
                               @Param("isEbook") Boolean isEbook,
                               @Param("isBestseller") Boolean isBestseller,
                               @Param("isNewArrival") Boolean isNewArrival,
                               Pageable pageable);
}
EOF

# ─── JWT Security ─────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/security/JwtTokenProvider.java << 'EOF'
package com.lithub.security;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.security.Key;
import java.util.Date;
@Component
@Slf4j
public class JwtTokenProvider {
    @Value("${lithub.jwt.secret}")
    private String jwtSecret;
    @Value("${lithub.jwt.expiration}")
    private long jwtExpiration;
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }
    public String generateToken(String username) {
        Date now = new Date();
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime() + jwtExpiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    public String getUsernameFromToken(String token) {
        return Jwts.parserBuilder().setSigningKey(getSigningKey()).build()
                .parseClaimsJws(token).getBody().getSubject();
    }
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            log.error("Invalid JWT: {}", e.getMessage());
            return false;
        }
    }
}
EOF

RUN cat > src/main/java/com/lithub/security/JwtAuthFilter.java << 'EOF'
package com.lithub.security;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {
    private final JwtTokenProvider tokenProvider;
    private final UserDetailsService userDetailsService;
    @Override
    protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws ServletException, IOException {
        try {
            String bearer = req.getHeader("Authorization");
            if (StringUtils.hasText(bearer) && bearer.startsWith("Bearer ")) {
                String jwt = bearer.substring(7);
                if (tokenProvider.validateToken(jwt)) {
                    String username = tokenProvider.getUsernameFromToken(jwt);
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    UsernamePasswordAuthenticationToken auth =
                            new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
                    SecurityContextHolder.getContext().setAuthentication(auth);
                }
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication", e);
        }
        chain.doFilter(req, res);
    }
}
EOF

# ─── Security Config ──────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/config/SecurityConfig.java << 'EOF'
package com.lithub.config;
import com.lithub.security.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.Arrays;
import java.util.List;
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {
    private final JwtAuthFilter jwtAuthFilter;
    private final UserDetailsService userDetailsService;
    @Value("${lithub.cors.allowed-origins}")
    private String allowedOrigins;
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(c -> c.disable())
            .cors(c -> c.configurationSource(corsSource()))
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(a -> a
                .requestMatchers("/api/auth/**", "/api/books/**", "/api/health").permitAll()
                .anyRequest().authenticated())
            .authenticationProvider(authProvider())
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
    @Bean
    public CorsConfigurationSource corsSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of(allowedOrigins.split(",")));
        config.setAllowedMethods(Arrays.asList("GET","POST","PUT","DELETE","OPTIONS"));
        config.setAllowedHeaders(Arrays.asList("Authorization","Content-Type"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
    @Bean
    public DaoAuthenticationProvider authProvider() {
        DaoAuthenticationProvider p = new DaoAuthenticationProvider();
        p.setUserDetailsService(userDetailsService);
        p.setPasswordEncoder(passwordEncoder());
        return p;
    }
    @Bean
    public AuthenticationManager authManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
    @Bean
    public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(12); }
}
EOF

# ─── UserDetailsService ───────────────────────────────────────────
RUN cat > src/main/java/com/lithub/service/UserDetailsServiceImpl.java << 'EOF'
package com.lithub.service;
import com.lithub.entity.User;
import com.lithub.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;
@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {
    private final UserRepository userRepository;
    @Override
    public UserDetails loadUserByUsername(String usernameOrEmail) throws UsernameNotFoundException {
        User user = userRepository.findByUsernameOrEmail(usernameOrEmail, usernameOrEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + usernameOrEmail));
        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .roles(user.getRole().name())
                .build();
    }
}
EOF

# ─── Auth Service ─────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/service/AuthService.java << 'EOF'
package com.lithub.service;
import com.lithub.dto.*;
import com.lithub.entity.User;
import com.lithub.repository.UserRepository;
import com.lithub.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.security.SecureRandom;
import java.time.LocalDateTime;
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authManager;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByUsername(req.getUsername()))
            throw new RuntimeException("Username already taken");
        if (userRepository.existsByEmail(req.getEmail()))
            throw new RuntimeException("Email already registered");
        String otp = String.valueOf(new SecureRandom().nextInt(900000) + 100000);
        User user = User.builder()
                .username(req.getUsername())
                .email(req.getEmail())
                .password(passwordEncoder.encode(req.getPassword()))
                .nickname(req.getNickname())
                .gender(req.getGender())
                .age(req.getAge())
                .isVerified(false)
                .otpCode(otp)
                .otpExpiresAt(LocalDateTime.now().plusMinutes(10))
                .build();
        userRepository.save(user);
        log.info("OTP for {}: {}", req.getEmail(), otp);
        return buildResponse(user);
    }

    public AuthResponse login(LoginRequest req) {
        authManager.authenticate(new UsernamePasswordAuthenticationToken(req.getUsernameOrEmail(), req.getPassword()));
        User user = userRepository.findByUsernameOrEmail(req.getUsernameOrEmail(), req.getUsernameOrEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return buildResponse(user);
    }

    @Transactional
    public AuthResponse verifyOtp(OtpRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (!req.getOtp().equals(user.getOtpCode()))
            throw new RuntimeException("Invalid OTP");
        if (LocalDateTime.now().isAfter(user.getOtpExpiresAt()))
            throw new RuntimeException("OTP expired");
        user.setIsVerified(true);
        user.setOtpCode(null);
        userRepository.save(user);
        return buildResponse(user);
    }

    private AuthResponse buildResponse(User user) {
        String token = tokenProvider.generateToken(user.getUsername());
        UserResponse ur = UserResponse.builder()
                .id(user.getId()).username(user.getUsername())
                .email(user.getEmail()).nickname(user.getNickname())
                .isVerified(user.getIsVerified()).role(user.getRole().name())
                .createdAt(user.getCreatedAt()).build();
        return AuthResponse.builder().token(token).tokenType("Bearer").user(ur).build();
    }
}
EOF

# ─── Book Service ─────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/service/BookService.java << 'EOF'
package com.lithub.service;
import com.lithub.dto.BookResponse;
import com.lithub.entity.Book;
import com.lithub.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;
@Service
@RequiredArgsConstructor
public class BookService {
    private final BookRepository bookRepository;
    public Page<BookResponse> getBooks(String search, String genre, Boolean isEbook,
                                       Boolean isBestseller, Boolean isNewArrival,
                                       int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("id").ascending());
        return bookRepository.findWithFilters(search, genre, isEbook, isBestseller, isNewArrival, pageable)
                .map(this::map);
    }
    public BookResponse getBook(Long id) {
        return bookRepository.findById(id).map(this::map)
                .orElseThrow(() -> new RuntimeException("Book not found"));
    }
    private BookResponse map(Book b) {
        return BookResponse.builder()
                .id(b.getId()).title(b.getTitle()).author(b.getAuthor())
                .description(b.getDescription()).price(b.getPrice())
                .genre(b.getGenre()).language(b.getLanguage())
                .pages(b.getPages()).year(b.getYear()).rating(b.getRating())
                .coverUrl(b.getCoverUrl()).stockCount(b.getStockCount())
                .isEbook(b.getIsEbook()).isBestseller(b.getIsBestseller())
                .isNewArrival(b.getIsNewArrival())
                .condition(b.getCondition().name()).build();
    }
}
EOF

# ─── Controllers ─────────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/controller/AuthController.java << 'EOF'
package com.lithub.controller;
import com.lithub.dto.*;
import com.lithub.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(authService.register(req), "Registration successful"));
    }
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest req) {
        return ResponseEntity.ok(ApiResponse.success(authService.login(req), "Login successful"));
    }
    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@RequestBody OtpRequest req) {
        return ResponseEntity.ok(ApiResponse.success(authService.verifyOtp(req), "Email verified"));
    }
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("LitHub API is running!");
    }
}
EOF

RUN cat > src/main/java/com/lithub/controller/BookController.java << 'EOF'
package com.lithub.controller;
import com.lithub.dto.*;
import com.lithub.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {
    private final BookService bookService;
    @GetMapping
    public ResponseEntity<ApiResponse<?>> getBooks(
            @RequestParam(required=false) String search,
            @RequestParam(required=false) String genre,
            @RequestParam(required=false) Boolean isEbook,
            @RequestParam(required=false) Boolean isBestseller,
            @RequestParam(required=false) Boolean isNewArrival,
            @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="12") int size) {
        return ResponseEntity.ok(ApiResponse.success(
                bookService.getBooks(search,genre,isEbook,isBestseller,isNewArrival,page,size),
                "Books retrieved"));
    }
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<BookResponse>> getBook(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(bookService.getBook(id), "Book retrieved"));
    }
}
EOF
package com.lithub.controller;

import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/app")
public class AppController {

    private Map<Long, String> orders = new HashMap<>();

    // 📖 Book Content (Page Flip)
    @GetMapping("/content/{bookId}")
    public String getContent(@PathVariable Long bookId) {
        return "Page 1: Welcome to LitHub\n" +
               "Page 2: This is your reader\n" +
               "Page 3: Flip pages smoothly\n" +
               "Page 4: Enjoy reading!";
    }

    // 📊 Save Reading Progress
    @PostMapping("/progress")
    public String saveProgress(@RequestParam Long userId,
                               @RequestParam Long bookId,
                               @RequestParam int page,
                               @RequestParam int totalPages) {

        double percent = ((double) page / totalPages) * 100;

        return "Progress saved: " + percent + "%";
    }

    // 💳 Create Order
    @PostMapping("/create")
    public Map<String, Object> createOrder(@RequestParam Long userId,
                                           @RequestParam Long bookId,
                                           @RequestParam int amount) {

        long orderId = new Random().nextLong();

        Map<String, Object> res = new HashMap<>();
        res.put("id", orderId);
        res.put("status", "PENDING");

        orders.put(orderId, "PENDING");

        return res;
    }

    // 💳 Pay Order
    @PostMapping("/pay/{id}")
    public String pay(@PathVariable Long id) {
        orders.put(id, "PAID");
        return "Payment successful";
    }
}

# ─── Exception Handler ────────────────────────────────────────────
RUN cat > src/main/java/com/lithub/exception/GlobalExceptionHandler.java << 'EOF'
package com.lithub.exception;
import com.lithub.dto.ApiResponse;
import org.springframework.http.*;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.*;
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiResponse<Void>> handleRuntime(RuntimeException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage()));
    }
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ApiResponse<Void>> handleBadCredentials(BadCredentialsException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Invalid username or password"));
    }
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGeneric(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Server error: " + ex.getMessage()));
    }
}
EOF

# ─── Build the app ────────────────────────────────────────────────
RUN mvn clean package -DskipTests -B

# ─── Stage 2: Run ────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/lithub-backend-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
