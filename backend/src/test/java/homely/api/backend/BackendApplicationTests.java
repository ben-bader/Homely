package homely.api.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import com.homely.BackendApplication;


@SpringBootTest(
    classes = BackendApplication.class,
    webEnvironment = SpringBootTest.WebEnvironment.NONE
)
@TestPropertySource(locations = "classpath:application.properties")
class BackendApplicationTests {

	@Test
	void contextLoads() {
	}

}
