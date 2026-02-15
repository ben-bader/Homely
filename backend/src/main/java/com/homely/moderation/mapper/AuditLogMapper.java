package com.homely.moderation.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.moderation.dto.AuditLogDto;
import com.homely.moderation.entity.AuditLog;

@Mapper(componentModel = "spring")
public interface AuditLogMapper {

    @Mapping(target = "adminId", source = "admin.id")
    @Mapping(target = "adminEmail", expression = "java(entity.getAdmin() != null ? entity.getAdmin().getEmail() : null)")
    @Mapping(target = "adminName", expression = "java(entity.getAdmin() != null ? entity.getAdmin().getName() : null)")
    AuditLogDto toDto(AuditLog entity);
}
