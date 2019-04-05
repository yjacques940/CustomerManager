﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using WebApi.Data;
using WebApi.DTO;
using WebApi.Models;
using WebApi.Validators;

namespace WebApi.Services
{
    public class AppointmentService : BaseCrudService<Appointment>
    {
        public AppointmentService(IWebApiContext context) : base(context)
        {
        }

        public ActionResult<IEnumerable<Appointment>> GetAppointmentsByDate(string date)
        {
            return Context.Appointments.Where(c => c.AppointmentDateTime.Date == Convert.ToDateTime(date).Date && c.IsActive).ToList();
        }

        public ActionResult<IEnumerable<CustomerAppointmentInformation>> GetAppointmentAndCustomers
            (CustomerPhoneNumberService customerPhoneNumberService)
        {
            var appointments = (
                from appointment in Context.Appointments
                join customer in Context.Customers on appointment.IdCustomer equals customer.Id
                where customer.IsActive && appointment.IsActive
                select new CustomerAppointmentInformation()
                {
                    Customer = customer,
                    Appointment = appointment
                }).AsNoTracking().ToList();

            foreach (var appointment in appointments)
            {
                appointment.PhoneNumbers = customerPhoneNumberService
                    .GetPhoneNumbersFromCustomerList(appointment.Customer.Id);
            }
            return appointments.OrderBy(c => c.Appointment.AppointmentDateTime).ToList();
        }
        public Appointment CheckAppointmentIsAvailable(AppointmentInformation appointment)
        {
            var appointmentConverted = ConvertDtoToModel(appointment);
            var appointmentsForTheDay = Context.Appointments.Where(c =>
                c.IsActive && appointmentConverted.AppointmentDateTime.Date == c.AppointmentDateTime.Date).ToList();

            return AppointmentValidator.IsAvailable(appointmentConverted, appointmentsForTheDay) == false ? null : appointmentConverted;
        }

        private Appointment ConvertDtoToModel(AppointmentInformation appointment)
        {
            return new Appointment()
            {
                AppointmentDateTime = Convert.ToDateTime(appointment.AppointmentDateTime),
                DurationTime = Convert.ToDateTime(appointment.DurationTime),
                IdCustomer = int.Parse(appointment.IdCustomer)
            };
        }

        public User GetUser(int appointmentId)
        {
            var customerId = Context.Appointments.First(c => c.Id == appointmentId).IdCustomer;
            return Context.Users.First(c => c.IdCustomer == customerId);
        }
    }
}