package homely.api.backend;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import com.homely.BackendApplication;
import com.homely.analytics.service.AdminAnalyticsService;

@SpringBootTest(
    classes = BackendApplication.class,
    webEnvironment = SpringBootTest.WebEnvironment.NONE
)
@TestPropertySource(locations = "classpath:application.properties")
class BackendApplicationTests {

    @Autowired
    private AdminAnalyticsService adminAnalyticsService;

    @Test
    void contextLoads() {
        System.out.println("🧪 Testing Overview Stats...");
        adminAnalyticsService.getOverviewStats();
        System.out.println("🧪 Testing User Growth Stats...");
        adminAnalyticsService.getUserGrowthStats();
        System.out.println("🧪 Testing Property Stats...");
        adminAnalyticsService.getPropertyStats();
        System.out.println("🧪 Testing Revenue Stats...");
        adminAnalyticsService.getRevenueStats();
        System.out.println("🧪 Testing Chat Stats...");
        adminAnalyticsService.getChatStats();
        System.out.println("🧪 Testing Engagement Stats...");
        adminAnalyticsService.getEngagementStats();
        System.out.println("🧪 Testing Moderation Stats...");
        adminAnalyticsService.getModerationStats();
        System.out.println("✅ All analytics methods executed successfully!");
    }
}
