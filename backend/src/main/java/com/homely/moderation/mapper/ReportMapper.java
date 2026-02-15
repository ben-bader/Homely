package com.homely.moderation.mapper;

import java.util.UUID;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;

@Mapper(componentModel = "spring")
public interface ReportMapper {

    @Mapping(target = "reporterId", source = "reporter.id")
    @Mapping(target = "reporterName", expression = "java(entity.getReporter() != null ? entity.getReporter().getName() : null)")
    @Mapping(target = "reporterEmail", expression = "java(entity.getReporter() != null ? entity.getReporter().getEmail() : null)")
    @Mapping(target = "reportedUserId", expression = "java(reportToReportedUserId(entity))")
    @Mapping(target = "reportedUserName", expression = "java(entity.getReportedUser() != null ? entity.getReportedUser().getName() : null)")
    @Mapping(target = "reportedUserEmail", expression = "java(entity.getReportedUser() != null ? entity.getReportedUser().getEmail() : null)")
    @Mapping(target = "reportedPropertyId", expression = "java(reportToReportedPropertyId(entity))")
    @Mapping(target = "reportedPropertyTitle", expression = "java(entity.getReportedProperty() != null ? entity.getReportedProperty().getTitle() : null)")
    @Mapping(target = "reviewedByAdminId", expression = "java(reportToReviewedByAdminId(entity))")
    @Mapping(target = "reviewedByAdminName", expression = "java(entity.getReviewedByAdmin() != null ? entity.getReviewedByAdmin().getName() : null)")
    @Mapping(target = "reviewedByAdminEmail", expression = "java(entity.getReviewedByAdmin() != null ? entity.getReviewedByAdmin().getEmail() : null)")
    ReportDto toDto(Report entity);

    default UUID reportToReportedUserId(Report r) {
        return r.getReportedUser() != null ? r.getReportedUser().getId() : null;
    }
    default UUID reportToReportedPropertyId(Report r) {
        return r.getReportedProperty() != null ? r.getReportedProperty().getId() : null;
    }
    default UUID reportToReviewedByAdminId(Report r) {
        return r.getReviewedByAdmin() != null ? r.getReviewedByAdmin().getId() : null;
    }
}
