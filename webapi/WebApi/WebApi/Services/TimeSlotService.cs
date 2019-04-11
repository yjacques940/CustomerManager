﻿using System.Collections.Generic;
using System.Linq;
using WebApi.Data;
using WebApi.Models;
using WebApi.Validators;

namespace WebApi.Services
{
    public class TimeSlotService : BaseCrudService<TimeSlot>
    {
        public TimeSlotService(IWebApiContext context) : base(context)
        {
        }

        public bool CreateNewTimeSlot(TimeSlot timeSlot)
        {
            if (timeSlot != null)
            {
                Context.Add(timeSlot);
                Context.SaveChanges();
                return true;
            }
            return false;
        }

        public bool IsAvailable(TimeSlot newTimeSlot)
        {
            List<TimeSlot> timeslots = Context.TimeSlots
                .Where(c => c.SlotDateTime.Date == newTimeSlot.SlotDateTime.Date).ToList();
            return TimeSlotValidator.IsAvailable(newTimeSlot, timeslots);
        }
    }
}
