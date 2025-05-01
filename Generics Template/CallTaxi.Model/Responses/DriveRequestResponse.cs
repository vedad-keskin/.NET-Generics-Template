using System;

namespace CallTaxi.Model.Responses
{
    public class DriveRequestResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int VehicleTierId { get; set; }
        public string VehicleTierName { get; set; } = string.Empty;

        // Driver information (nullable)
        public int? DriverId { get; set; }
        public string? DriverName { get; set; }

        // Vehicle information (nullable)
        public int? VehicleId { get; set; }
        public string? VehicleName { get; set; }
        public string? VehicleLicensePlate { get; set; }

        public string StartLocation { get; set; } = string.Empty;
        public string EndLocation { get; set; } = string.Empty;
        public decimal BasePrice { get; set; }
        public decimal FinalPrice { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? AcceptedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public int StatusId { get; set; }
        public string StatusName { get; set; } = string.Empty;
    }
} 